import { Application } from "@hotwired/stimulus"
import FileExportRefresherController from "./controllers/file_export_refresher_controller"
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
import CancellationFormController from "./controllers/cancellation_form_controller"
import NavigationController from "./controllers/navigation_controller"
import PinnedActionsController from "./controllers/pinned_actions_controller"
import DashboardChartController from "./controllers/dashboard_chart_controller"
import DiscountController from "./controllers/discount_controller"
import ExportTrayController from "./controllers/export_tray_controller"
import SyncDownloadController from "./controllers/sync_download_controller"
import ExportTriggerController from "./controllers/export_trigger_controller"
import DisclosureController from "./controllers/disclosure_controller"
import ReportRangeController from "./controllers/report_range_controller"

const application = Application.start()
application.register("file-export-refresher", FileExportRefresherController)
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
application.register("cancellation-form", CancellationFormController)
application.register("navigation", NavigationController)
application.register("pinned-actions", PinnedActionsController)
application.register("dashboard-chart", DashboardChartController)
application.register("discount", DiscountController)
application.register("export-tray", ExportTrayController)
application.register("sync-download", SyncDownloadController)
application.register("export-trigger", ExportTriggerController)
application.register("disclosure", DisclosureController)
application.register("report-range", ReportRangeController)

export { application }
