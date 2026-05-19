import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-toggle"
export default class extends Controller {
  static targets = ["select", "input"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isNew = this.selectTarget.value === "new"
    
    if (isNew) {
      this.inputTarget.classList.remove("hidden")
      this.inputTarget.querySelector("input").focus()
    } else {
      this.inputTarget.classList.add("hidden")
      this.inputTarget.querySelector("input").value = ""
    }
  }
}
