import { Application } from "@hotwired/stimulus"
import ShipmentItemController from "controllers/shipment_item_controller"

const nextTick = () => new Promise(resolve => setTimeout(resolve, 0))

function buildFixture() {
  document.body.innerHTML = `
    <div data-controller="shipment-item"
         data-shipment-item-prices-value='{"1":3.5,"2":4.25}'
         data-shipment-item-product-types-value='{"1":"Bread","2":"Pastry"}'>
      <select data-shipment-item-target="product"
              data-action="change->shipment-item#productChanged">
        <option value="1" selected>Existing product</option>
        <option value="2">Replacement product</option>
      </select>
      <input data-shipment-item-target="price" value="7.75">
      <span data-shipment-item-target="type">Historic type</span>
    </div>
  `
}

let application

beforeEach(() => {
  buildFixture()
  application = Application.start()
  application.register("shipment-item", ShipmentItemController)
})

afterEach(() => {
  application.stop()
  document.body.innerHTML = ""
})

test("preserves the saved invoice price when an existing row connects", async () => {
  await nextTick()

  expect(document.querySelector("[data-shipment-item-target='price']").value).toBe("7.75")
})

test("fills the current price only after staff choose a different product", async () => {
  await nextTick()

  const product = document.querySelector("[data-shipment-item-target='product']")
  product.value = "2"
  product.dispatchEvent(new Event("change", { bubbles: true }))

  expect(document.querySelector("[data-shipment-item-target='price']").value).toBe("4.25")
  expect(document.querySelector("[data-shipment-item-target='type']").textContent).toBe("Pastry")
})
