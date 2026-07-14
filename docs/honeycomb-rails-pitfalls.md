# Rails + Honeycomb/OpenTelemetry pitfalls

Reference checklist for anyone touching `config/initializers/opentelemetry.rb`.
Written after a real incident (2026-07-05): a custom `SpanProcessor` was added
to drop Solid Queue/Solid Cable polling spans by matching `db.statement`
against known table names. It didn't work — Solid Queue wraps its poll query
in an explicit transaction, so each poll produces a `BEGIN`, the query, and a
`COMMIT` span. Only the query span's `db.statement` mentions the table name;
`BEGIN`/`COMMIT` just say `"BEGIN"`/`"COMMIT"`, so they kept exporting at full
volume even after the "fix." The actual fix suppressed span creation at the
source instead (see below) rather than trying to filter it out after export.

## The core lesson: suppress at the source, not after export

**Don't write a custom `SpanProcessor` that inspects span attributes to decide
what's noise.** A span processor only sees one span at a time, in isolation —
it has no reliable way to know "this BEGIN belongs to the same logical
operation as that SELECT I already decided to drop," short of re-implementing
trace-aware buffering yourself (which is exactly the kind of stateful,
easy-to-get-wrong logic we shipped and then had to walk back).

Instead, use `OpenTelemetry::Common::Utilities.untraced`:

```ruby
OpenTelemetry::Common::Utilities.untraced { do_the_noisy_thing }
```

This works because the check happens in the SDK's `TracerProvider` itself —
`untraced?` is checked before *any* span is started
(`opentelemetry-sdk-1.12.0/lib/opentelemetry/sdk/trace/tracer_provider.rb`),
not by each instrumentation library individually. So wrapping one call site
suppresses every span nested inside it — including transaction wrapper spans
generated deep inside ActiveRecord/pg — with zero ingest cost, since the spans
are never created at all.

**Caveat (confirmed via [OTel Ruby discussion #1333](https://github.com/open-telemetry/opentelemetry-ruby/discussions/1333)):**
`untraced` only works with a `ParentBased` sampler. If the SDK is configured
with `OTEL_TRACES_SAMPLER=always_on` (or any non-`ParentBased` custom
sampler), `untraced` silently does nothing — the sampler ignores the parent's
trace flags and samples everything anyway. Our config doesn't set
`OTEL_TRACES_SAMPLER` at all, which defaults to `ParentBased(root=AlwaysOn)`,
so this is fine today — but if a sampler override is ever added, re-verify
`untraced` still works.

### Check for a narrower, built-in knob first

Before reaching for `untraced` or a custom processor, check whether the
specific instrumentation gem already has a config option for this. Confirmed
example: `opentelemetry-instrumentation-rack` has `untraced_endpoints`
(and `untraced_requests` for pattern-based matching):

```ruby
c.use "OpenTelemetry::Instrumentation::Rack", untraced_endpoints: ["/health", "/probes/ready"]
```

(source: [OTel Ruby discussion #640](https://github.com/open-telemetry/opentelemetry-ruby/discussions/640) —
also notes that instrumentation options must be set via `c.use`/`c.use_all`,
not by reaching into the instrumentation instance directly, or the config
gets silently clobbered.)

`opentelemetry-instrumentation-pg` (0.36.0, what we run) has no equivalent
per-query filter — only `db_statement: :include | :omit | :obfuscate`
(we're on `:obfuscate`, the default: literals are redacted but table/column
names are kept). There is no built-in way to exclude specific tables or
queries from tracing at the pg-instrumentation level, which is why `untraced`
at the call site is the right tool for DB-level noise specifically.

## Solid Queue/Solid Cable polling: this is a known, still-unresolved gap

[rails/solid_queue#311](https://github.com/rails/solid_queue/issues/311)
is the exact same complaint we hit, filed independently: `SolidQueue.silence_polling?`
silences the ActiveRecord *logger* but does nothing about tracing —
polling still generates full-volume `BEGIN`/`COMMIT`/query spans. The
reporter's workaround was tagging polling spans with a custom attribute
(`"polling.solid_queue" => "true"`) to filter downstream, which they
themselves called "a hack" — same shape of fix we initially shipped and had
to replace.

As of solid_queue 1.4.0 (installed here), `with_polling_volume` in
`SolidQueue::Processes::Poller` still only gates the *logger*:

```ruby
def with_polling_volume
  SolidQueue.instrument(:polling) do
    if SolidQueue.silence_polling? && ActiveRecord::Base.logger
      ActiveRecord::Base.logger.silence { yield }
    else
      yield
    end
  end
end
```

There is no upstream OTel-aware suppression. **This means our `prepend`-based
fix in `config/initializers/opentelemetry.rb` (wrapping
`with_polling_volume` in both `SolidQueue::Processes::Poller` and
`ActionCable::SubscriptionAdapter::SolidCable::Listener` with
`OpenTelemetry::Common::Utilities.untraced`) is currently the only way to
kill this noise, and it will need re-verifying against the gem's actual
method signature on every solid_queue/solid_cable version bump** — if either
gem restructures where polling happens (e.g. no longer funnels through a
single `with_polling_volume` method), the `prepend` silently stops working
and the noise comes back with no error raised.

## Checklist: noise sources to audit before/after enabling `use_all`

`use_all` (what we use) auto-instruments every supported gem present —
deliberate, per Honeycomb's own philosophy of wide events over pre-curated
spans ([Honeycomb OTel best practices](https://www.honeycomb.io/blog/opentelemetry-best-practices):
"enable all available auto-instrumentation initially... then dial back
non-valuable signals"). But "dial back" needs to actually happen. Check for:

- [x] **Solid Queue poller** (Worker + Dispatcher) — handled via `untraced` prepend.
- [x] **Solid Cable listener** — handled via `untraced` prepend.
- [ ] **Recurring jobs** (`config/recurring.yml`) — these run on a fixed
      schedule too; if any of them run sub-minute or produce large fan-out
      (e.g. per-record loops), check their span volume in Honeycomb
      periodically, same way the poller was caught.
- [ ] **Health-check / uptime-monitor endpoints**, if any get added — use
      `untraced_endpoints` on the Rack instrumentation rather than a custom
      filter (see above).
- [ ] **N+1 queries** — auto-instrumented ActiveRecord spans mean an N+1 shows
      up as N nearly-identical child spans per request/trace. Not "noise" in
      the same sense (it's real, and arguably useful signal for finding the
      N+1), but worth knowing this inflates per-trace span count and ingest
      volume proportionally to the bug, not to real load.
- [ ] **Any new background poller** added later (cron-style thread loops,
      external API polling, queue consumers) — same pattern as Solid
      Queue/Cable: check whether it funnels through one method you can wrap
      in `untraced`, before reaching for a post-hoc filter.

## Sampling and cost control (for when suppression isn't the right tool)

Suppression (`untraced`) is for "this specific operation should never be
traced, ever" — a poller is a good fit because it's 100% noise, 0% signal.
For traffic that's real but too voluminous to keep 100% of (e.g. a
high-traffic, low-value endpoint), Honeycomb's model is different from
suppression:

- **Head sampling** (decision made at trace start, before span content is
  known): `TraceIdRatioBased` sampler, e.g. keep 1-in-N traces. When doing
  this, set a `SampleRate` resource attribute matching N so Honeycomb can
  reweight counts/sums back to true values instead of undercounting.
  ([Honeycomb Ruby OTel docs](https://docs.honeycomb.io/getting-data-in/opentelemetry/ruby/))
- **Tail sampling** (decision made after the full trace is known, so it can
  keep 100% of errors/slow traces while dropping routine successes) —
  Honeycomb's own tool for this is [Refinery](https://github.com/honeycombio/refinery),
  a trace-aware sampling proxy supporting dynamic, rules-based, and
  throughput-based sampling. This is a separate deployed component, not SDK
  config — relevant only if/when volume from *real* traffic (not pollers)
  becomes a cost problem.
- We are not currently running Refinery or any ratio-based sampler — the
  `use_all` + targeted `untraced` combination is sufficient at current scale
  (see CLAUDE.md: Bien Cuit is effectively the only real tenant, so real
  traffic volume is modest). Revisit if span volume from genuine requests
  (not background noise) becomes the cost driver.

## High-cardinality attribute gotchas

Honeycomb's pricing/ingest model is flat per-event regardless of attribute
count, and every attribute is queryable without pre-indexing — so, unlike
metrics systems, adding attributes isn't inherently expensive
([Honeycomb: High Cardinality](https://docs.honeycomb.io/get-started/observability/concepts/high-cardinality)).
The risk isn't "too many attributes," it's:

- Attributes with unbounded/PII-adjacent values (raw emails, full URLs with
  embedded IDs, request bodies) — fine for Honeycomb's ingest cost model, but
  a data-hygiene/PII concern independent of tracing cost. `db.statement` is
  already set to `:obfuscate` here for this reason — don't switch it to
  `:include` without checking what literals might leak (e.g. customer PII in
  a `WHERE email = '...'` clause) — see CLAUDE.md's PII-handling norms
  elsewhere in the app before changing this.
- Volume, not cardinality, was actually our problem: the poller issue was
  about span *count* (one full trace per poll tick, forever), not attribute
  cardinality. Don't reach for a cardinality-focused fix (e.g. dropping
  attributes) when the actual problem is span volume — the right question is
  "should this operation produce a trace at all," not "should this trace have
  fewer fields."

## Attribute naming conventions

Custom (non-semantic-convention) attribute keys are still few enough (6
distinct keys, listed below) that this is one short section, not a separate
schema doc —
revisit that if the table below grows past ~a dozen entries, or if attributes
start getting relied on by a Honeycomb dashboard/SLO/trigger (a silent rename
would then break a saved query, not just a search).

**Rule: `<entity>.<field>`**, where `<entity>` is the Rails model name,
snake_case and singular (`production_run`, not `production-runs` or
`ProductionRun`), and `<field>` matches the model's own column/method name
where one exists (`id`, `item_count`). Pick the entity that's actually the
subject of the attribute, not just whatever object happens to be in scope —
e.g. `production_run.item_count` lives on the report span even though the
code computing it is `ProductionRunGenerator`, because the count describes
the production run, not the generator.

**Exception: reserved cross-cutting keys.** A tiny second category exists for
identifiers that should be filterable on *every* span regardless of what
entity that span's own logic is about — currently just tenant identity.
Instead of every emitter inventing its own entity-scoped foreign-key
attribute (`file_export.bakery_id`, `production_run.bakery_id`, etc.), use the
single reserved key below so a Honeycomb query can filter by tenant across
unrelated span types, and across the frontend/backend boundary:

| Reserved key | Type | Meaning |
|---|---|---|
| `bakery.id` | **string** | The current tenant. Always a string — the frontend can only ever read it out of an HTML `<meta>` tag, so the backend `.to_s`-coerces its (integer) `bakery_id` column to match. Sending it as an integer from one side and a string from the other would make an exact-match filter like `bakery.id = 5` silently miss whichever side didn't match. |

**Caveat: span attributes don't inherit to child spans.** Unlike the
frontend's `WebTracerProvider` *resource* attribute (set once, stamped onto
every span the page produces automatically), a backend span attribute set via
`add_attributes`/`in_span(attributes:)` only lives on that one span event —
Honeycomb has no notion of a child span inheriting a parent's attributes.
`bakery.id` is therefore set independently at each place it's needed, not
once: `app/jobs/exporter_job.rb` (`tag_current_span`, on the ActiveJob
`perform` span) and `app/reports/production_run_generator.rb`
(`report_attributes`, on the `report.generate` span and its
`production_run.build_data`/`production_run.render_pdf` children). A query
scoped to one specific span type needs `bakery.id` set on *that* span type
directly — being present somewhere else in the same trace doesn't help.
Other generators that want tenant-filterable report spans need their own
`report_attributes` entry for it; there's no shared default yet.

Before adding a new entity-scoped attribute, check whether it's actually
identifying the tenant rather than something specific to that entity — if so,
it belongs under `bakery.id`, not a new `<entity>.bakery_id` key.

### Current custom keys

| Key | Entity namespace | Set in | Notes |
|---|---|---|---|
| `report.type` | `report` | `app/reports/generator.rb` (`Generator::Instrumentation`) | Report class name, e.g. `production_run`. Applies to every report generator via the shared concern. |
| `production_run.id` | `production_run` | `app/reports/production_run_generator.rb` (`report_attributes`) | Merged onto the `report.generate` span by `Generator::Instrumentation`. |
| `production_run.item_count` | `production_run` | `app/reports/production_run_generator.rb` (`report_attributes`) | Same mechanism — lets a slow trace be told apart from a large one. |
| `file_export.id` | `file_export` | `app/jobs/exporter_job.rb` (`tag_current_span`) | |
| `file_export.user_id` | `file_export` | `app/jobs/exporter_job.rb` (`tag_current_span`) | |
| `bakery.id` | *(reserved, see above)* | `app/jobs/exporter_job.rb`, `app/reports/production_run_generator.rb`, `app/assets/javascripts/otel_web.js` | Shared tenant key, not entity-scoped. Set independently in each place per the inheritance caveat above. |

Any generator can add more report-specific attributes the same way
`ProductionRunGenerator` does: define a public `report_attributes` method
returning a Hash, and `Generator::Instrumentation#generate` merges it onto
the `report.generate` span automatically — no per-generator span-wrapping
needed.

## Sources

- [OTel Ruby discussion #1333 — `untraced` requires `ParentBased` sampler](https://github.com/open-telemetry/opentelemetry-ruby/discussions/1333)
- [OTel Ruby discussion #640 — `untraced_endpoints` for Rack instrumentation](https://github.com/open-telemetry/opentelemetry-ruby/discussions/640)
- [rails/solid_queue#311 — polling noise in tracing, `silence_polling?` doesn't cover it](https://github.com/rails/solid_queue/issues/311)
- [Honeycomb: OpenTelemetry Ruby setup docs](https://docs.honeycomb.io/getting-data-in/opentelemetry/ruby/)
- [Honeycomb: "5-Star OTel" best practices](https://www.honeycomb.io/blog/opentelemetry-best-practices)
- [Honeycomb: Sampling docs](https://docs.honeycomb.io/manage-data-volume/sample)
- [Honeycomb: High Cardinality concepts](https://docs.honeycomb.io/get-started/observability/concepts/high-cardinality)
- [honeycombio/refinery README](https://github.com/honeycombio/refinery/blob/main/README.md)
- Local gem source read directly: `opentelemetry-sdk-1.12.0/lib/opentelemetry/sdk/trace/tracer_provider.rb`,
  `solid_queue-1.4.0/lib/solid_queue/processes/poller.rb`,
  `solid_cable-4.0.0/lib/action_cable/subscription_adapter/solid_cable.rb`
