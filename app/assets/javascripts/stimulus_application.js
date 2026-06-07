import { Application } from "@hotwired/stimulus"
import FileExportRefresherController from "./controllers/file_export_refresher_controller"
import ClientMapController from "./controllers/client_map_controller"
import NestedFormController from "./controllers/nested_form_controller"
import FilterTableController from "./controllers/filter_table_controller"
import IngredientFilterController from "./controllers/ingredient_filter_controller"
import IngredientRowController from "./controllers/ingredient_row_controller"
import TomSelectController from "./controllers/tom_select_controller"
import OrderFormController from "./controllers/order_form_controller"
import OrderItemController from "./controllers/order_item_controller"
import ShipmentItemController from "./controllers/shipment_item_controller"
import RecipeFormController from "./controllers/recipe_form_controller"
import RecipeItemController from "./controllers/recipe_item_controller"

const application = Application.start()
application.register("file-export-refresher", FileExportRefresherController)
application.register("client-map", ClientMapController)
application.register("nested-form", NestedFormController)
application.register("filter-table", FilterTableController)
application.register("ingredient-filter", IngredientFilterController)
application.register("ingredient-row", IngredientRowController)
application.register("tom-select", TomSelectController)
application.register("order-form", OrderFormController)
application.register("order-item", OrderItemController)
application.register("shipment-item", ShipmentItemController)
application.register("recipe-form", RecipeFormController)
application.register("recipe-item", RecipeItemController)

export { application }
