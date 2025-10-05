import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input"]

    connect() {
        this.clearOnTurbo = this.clearOnTurbo.bind(this)
        this.clearOnAjax = this.clearOnAjax.bind(this)

        this.element.addEventListener("turbo:submit-end", this.clearOnTurbo)
        this.element.addEventListener("ajax:complete", this.clearOnAjax)
    }

    disconnect() {
        this.element.removeEventListener("turbo:submit-end", this.clearOnTurbo)
        this.element.removeEventListener("ajax:complete", this.clearOnAjax)
    }

    // Focus the input when container is clicked, but ignore clicks on interactive elements.
    focusInput(event) {
        const tag = event.target.tagName
        const interactiveTags = new Set(["INPUT", "TEXTAREA", "BUTTON", "A", "SELECT", "LABEL"])
        if (interactiveTags.has(tag) || event.target.closest("[data-no-focus]")) return
        this.inputTarget.focus()
    }

    clearOnTurbo(event) {
        if (!this.hasInputTarget) return
        // turbo:submit-end provides event.detail.success
        if (event.detail && event.detail.success) {
            this.inputTarget.value = ""
        }
    }

    clearOnAjax(event) {
        if (!this.hasInputTarget) return
        // rails-ujs: event.detail = [xhr, status, error]
        const status = event.detail && event.detail[1]
        if (status === "success" || status === "ok") {
            this.inputTarget.value = ""
        }
    }
}
