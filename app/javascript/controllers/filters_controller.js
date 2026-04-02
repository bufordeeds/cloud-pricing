import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  submit() {
    this.formTarget.requestSubmit()
  }

  debounceSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.submit(), 300)
  }
}
