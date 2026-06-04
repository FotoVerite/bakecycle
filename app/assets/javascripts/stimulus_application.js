import { Application } from "@hotwired/stimulus"
import FileExportRefresherController from "./controllers/file_export_refresher_controller"

const application = Application.start()
application.register("file-export-refresher", FileExportRefresherController)

export { application }
