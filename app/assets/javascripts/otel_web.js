import { trace } from "@opentelemetry/api"
import { WebTracerProvider } from "@opentelemetry/sdk-trace-web"
import { BatchSpanProcessor } from "@opentelemetry/sdk-trace-base"
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http"
import { resourceFromAttributes } from "@opentelemetry/resources"
import { ATTR_SERVICE_NAME } from "@opentelemetry/semantic-conventions"
import { registerInstrumentations } from "@opentelemetry/instrumentation"
import { DocumentLoadInstrumentation } from "@opentelemetry/instrumentation-document-load"
import { FetchInstrumentation } from "@opentelemetry/instrumentation-fetch"
import { XMLHttpRequestInstrumentation } from "@opentelemetry/instrumentation-xml-http-request"
import { ZoneContextManager } from "@opentelemetry/context-zone"

// Frontend RUM traces relay through our own /otel/v1/traces endpoint (see
// OtelTracesController) rather than exporting straight to Honeycomb, so the
// browser never needs a Honeycomb API key and there's no CORS to configure --
// the Rails proxy forwards using the same OTEL_EXPORTER_OTLP_* env vars the
// backend's own OpenTelemetry SDK already uses (config/initializers/opentelemetry.rb).
function metaContent(name) {
  return document.querySelector(`meta[name="${name}"]`)?.content
}

export let tracer = null

const environment = metaContent("otel-environment")

if (environment) {
  const attributes = { [ATTR_SERVICE_NAME]: `bakecycle-frontend-${environment}` }
  const bakeryId = metaContent("otel-bakery-id")
  if (bakeryId) attributes["bakery.id"] = bakeryId

  const provider = new WebTracerProvider({
    resource: resourceFromAttributes(attributes),
    spanProcessors: [
      new BatchSpanProcessor(new OTLPTraceExporter({ url: "/otel/v1/traces" })),
    ],
  })

  provider.register({ contextManager: new ZoneContextManager() })

  registerInstrumentations({
    instrumentations: [
      new DocumentLoadInstrumentation(),
      new FetchInstrumentation({ propagateTraceHeaderCorsUrls: [window.location.origin] }),
      new XMLHttpRequestInstrumentation({ propagateTraceHeaderCorsUrls: [window.location.origin] }),
    ],
  })

  tracer = trace.getTracer("bakecycle-frontend")
}
