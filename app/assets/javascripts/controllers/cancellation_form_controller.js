import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "clientRow", "nameFilter", "routeFilter", "count",
    "cart", "cartList", "cartCount", "cartEmpty", "hiddenInputs", "submit"
  ]

  connect() {
    this.selected = new Map()
    this.clientRowTargets.forEach(row => {
      if (row.dataset.selected === "true") this._select(row)
    })
    this.filter()
    this._render()
  }

  changeDate(event) {
    const date = event.target.value
    if (!date) return

    const url = new URL(window.location.href)
    url.searchParams.set("date", date)
    url.searchParams.delete("client_ids[]")
    this.selected.forEach((_client, id) => url.searchParams.append("client_ids[]", id))
    window.location.href = url.toString()
  }

  filter() {
    const name  = this.nameFilterTarget.value.toLowerCase().trim()
    const route = this.routeFilterTarget.value

    let visible = 0
    this.clientRowTargets.forEach(row => {
      const matchName  = !name  || row.dataset.name.toLowerCase().includes(name)
      const matchRoute = !route || row.dataset.routeId === route
      const show = matchName && matchRoute
      row.hidden = !show
      if (show) visible++
    })

    this.countTarget.textContent = visible === this.clientRowTargets.length
      ? `${visible} clients`
      : `${visible} of ${this.clientRowTargets.length} clients`
  }

  selectAllVisible() {
    this.clientRowTargets.forEach(row => {
      if (!row.hidden && !this.selected.has(row.dataset.id)) this._select(row)
    })
    this._render()
  }

  toggleClient(event) {
    const row = event.currentTarget
    if (this.selected.has(row.dataset.id)) {
      this._deselect(row.dataset.id)
    } else {
      this._select(row)
    }
    this._render()
  }

  removeFromCart(event) {
    this._deselect(event.currentTarget.dataset.id)
    this._render()
  }

  toggleMobileCart() {
    this.cartTarget.classList.toggle("cancellation-cart-expanded")
  }

  _select(row) {
    this.selected.set(row.dataset.id, {
      id: row.dataset.id,
      name: row.dataset.name,
      route: row.dataset.routeName || ""
    })
    row.dataset.selected = "true"
    row.setAttribute("aria-pressed", "true")
  }

  _deselect(id) {
    this.selected.delete(id)
    const row = this.clientRowTargets.find(r => r.dataset.id === id)
    if (row) {
      row.dataset.selected = "false"
      row.setAttribute("aria-pressed", "false")
    }
  }

  _render() {
    this._syncCartItems()
    this._syncHiddenInputs()

    const count = this.selected.size
    this.cartCountTarget.textContent = count
    this.cartEmptyTarget.hidden = count > 0
    this.cartListTarget.hidden = count === 0
    this.submitTarget.disabled = count === 0
    this.cartTarget.classList.toggle("has-selection", count > 0)
  }

  _syncCartItems() {
    const selectedIds = new Set(this.selected.keys())

    this.cartListTarget.querySelectorAll(".cancellation-cart-item").forEach(item => {
      if (!selectedIds.has(item.dataset.id)) item.remove()
    })

    this.selected.forEach(client => {
      let item = this.cartListTarget.querySelector(`.cancellation-cart-item[data-id="${client.id}"]`)

      if (!item) {
        item = this._buildCartItem(client)
        this.cartListTarget.appendChild(item)
      }
    })
  }

  _syncHiddenInputs() {
    const inputs = []

    this.selected.forEach(client => {
      const hidden = document.createElement("input")
      hidden.type = "hidden"
      hidden.name = "client_ids[]"
      hidden.value = client.id
      inputs.push(hidden)
    })

    this.hiddenInputsTarget.replaceChildren(...inputs)
  }

  _buildCartItem(client) {
    const item = document.createElement("li")
    item.className = "cancellation-cart-item"
    item.dataset.id = client.id

    const name = document.createElement("span")
    name.className = "cancellation-cart-item-name"
    name.textContent = client.name
    item.appendChild(name)

    if (client.route) {
      const route = document.createElement("span")
      route.className = "cancellation-cart-item-route"
      route.textContent = client.route
      item.appendChild(route)
    }

    const remove = document.createElement("button")
    remove.type = "button"
    remove.className = "cancellation-cart-item-remove"
    remove.dataset.id = client.id
    remove.dataset.action = "click->cancellation-form#removeFromCart"
    remove.setAttribute("aria-label", `Remove ${client.name}`)
    remove.innerHTML = '<span aria-hidden="true">&times;</span>'
    item.appendChild(remove)

    return item
  }
}
