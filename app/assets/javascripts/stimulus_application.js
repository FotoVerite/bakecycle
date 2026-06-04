import { Application } from "@hotwired/stimulus"
import FileExportRefresherController from "./controllers/file_export_refresher_controller"
import ClientMapController from "./controllers/client_map_controller"
import NestedFormController from "./controllers/nested_form_controller"
import FilterTableController from "./controllers/filter_table_controller"
import IngredientFilterController from "./controllers/ingredient_filter_controller"
import IngredientRowController from "./controllers/ingredient_row_controller"

const application = Application.start()
application.register("file-export-refresher", FileExportRefresherController)
application.register("client-map", ClientMapController)
application.register("nested-form", NestedFormController)
application.register("filter-table", FilterTableController)
application.register("ingredient-filter", IngredientFilterController)
application.register("ingredient-row", IngredientRowController)

export { application }
