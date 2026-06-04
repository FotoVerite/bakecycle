## Design Context

### Users

Two audiences in equal measure:

**Bakery owners and managers** — use the app at a desk for scheduling, client management, pricing, and production planning. They navigate across many screens in a session and care about data accuracy and speed.

**Production staff** — bakers and kitchen leads checking run sheets, ingredient quantities, and packing lists, often on a shared screen or tablet in the kitchen. They need fast scanning, clear hierarchy, and large enough touch targets to work with floury hands.

Any design decision should hold up for both contexts: dense enough for the office, legible enough for the floor.

---

### Brand Personality

**Reliable workhorse.** Bakecycle is a tool, not a showpiece. It earns trust by getting out of the way and letting operators do their jobs. Professional and direct, with just enough warmth to feel human — not cold enterprise software, not a lifestyle brand.

Three words: **dependable, clear, grounded**

---

### Aesthetic Direction

**Warmer and more approachable** than the current palette, but not a full replacement — evolve, don't rebrand.

- Shift cool greys (`#f2f3f4`, `#787878`) toward warmer stone and warm grey tones
- Retain Shakespeare blue (`#55aad7`) as the primary interactive/brand color — it's established and readable
- Replace the near-black top bar (`#2d2f3b`) with something slightly warmer if touching that component
- Open Sans stays — it reads well at small sizes and across weight ranges (300–700 is the working range)
- Avoid anything that reads as "startup SaaS pastels" or clinical cold white — this is for people who wake up at 4am to make bread

**Anti-reference:** bare Foundation 5 defaults, dark mode only, ultra-minimal whitespace

---

### Design Principles

1. **Clarity first** — Every screen should have one obvious primary action. Data tables and forms are unavoidable; use visual weight (not decoration) to show what matters most.

2. **Consistent component vocabulary** — One button style, one form field style, one table style — used everywhere without local overrides. This is the primary gap to close. New work should always refer back to these patterns, not invent local ones.

3. **Warmth through spacing, not color** — Don't add more colors to solve visual problems. Use generous padding and grouping to make dense pages breathable. Whitespace is the warm touch.

4. **Floor-legible type** — Body text should be at least `0.9rem` but headings and key data values should be larger than they feel like they need to be on a desktop. Production staff may be reading from 2 feet away.

5. **Incremental, not systemic** — Bakecycle is mid-upgrade. New design work should improve individual components in place rather than requiring a full design system overhaul before shipping.

---

### Current Token Reference

| Token | Value | Usage |
|---|---|---|
| `$bc-shakespeare` | `#55aad7` | Primary brand blue — links, active states, accents |
| `$bc-limed-spruce` | `#323c46` | Dark header/nav backgrounds |
| `$bc-alizarin-crimson` | `#eb3232` | Destructive / error red |
| `$bc-lima` | `#7ed321` | Success green |
| `$bc-scorpion` | `#5a5a5a` | Body text |
| `$bc-charcoal` | `#555` | Headings, table text |
| `$bc-off-white` | `#f2f3f4` | Page background |
| `$bc-lightgrey` | `#dcdcdc` | Borders |

Font: **Open Sans**, weights 300 / 400 / 600 / 700 / 800, self-hosted via `font_setup.scss`.
