import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "bar", "count", "link"]

  updateCompare() {
    const selected = this.checkboxTargets.filter(cb => cb.checked)
    const ids = selected.map(cb => cb.value)

    if (ids.length >= 2) {
      this.barTarget.classList.remove("hidden")
      this.countTarget.textContent = ids.length
      this.linkTarget.href = `/compare?ids=${ids.join(",")}`
    } else {
      this.barTarget.classList.add("hidden")
    }
  }

  goCompare(event) {
    event.preventDefault()
    window.location.href = this.linkTarget.href
  }
}
