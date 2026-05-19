import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["controls"]
  static values = {
    ownerId: String
  }

  connect() {
    this.checkPermissions()
  }

  checkPermissions() {
    const metaTag = document.querySelector('meta[name="current-user-id"]')
    if (!metaTag) return

    const currentUserId = metaTag.getAttribute("content")
    if (currentUserId === this.ownerIdValue) {
      this.controlsTarget.classList.remove("hidden")
    }
  }
}
