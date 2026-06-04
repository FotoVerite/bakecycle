import { Application } from "@hotwired/stimulus"
import FileExportRefresherController from "./controllers/file_export_refresher_controller"
import ClientMapController from "./controllers/client_map_controller"
import NestedFormController from "./controllers/nested_form_controller"

const application = Application.start()
application.register("file-export-refresher", FileExportRefresherController)
application.register("client-map", ClientMapController)
application.register("nested-form", NestedFormController)

export { application }
