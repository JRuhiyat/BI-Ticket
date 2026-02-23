// controllers/upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton"]

  submit() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.classList.add("opacity-50")
    this.submitButtonTarget.value = "Processing..."
  }
}