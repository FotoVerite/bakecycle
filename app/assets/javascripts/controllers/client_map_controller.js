import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lat: Number, lng: Number, name: String, apiKey: String, address: String }

  connect() {
    if (window.google?.maps) {
      this.initMap()
    } else {
      const script = document.createElement("script")
      script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}`
      script.onload = () => this.initMap()
      document.head.appendChild(script)
    }
  }

  initMap() {
    const center = { lat: this.latValue, lng: this.lngValue }
    const map = new google.maps.Map(this.element, {
      center,
      zoom: 15,
      scrollwheel: false,
      draggable: false,
      minZoom: 15,
      maxZoom: 15,
    })
    const marker = new google.maps.Marker({ position: center, map, title: this.nameValue })
    marker.addListener("click", () => {
      window.open(`https://maps.google.com/?q=${encodeURIComponent(this.addressValue)}`)
    })
  }
}
