import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleAll(event) {
    const checked = event.target.checked
    document.querySelectorAll("[data-compare-select-target='checkbox']").forEach(cb => {
      cb.checked = checked
      cb.dispatchEvent(new Event("change"))
    })
  }
}
