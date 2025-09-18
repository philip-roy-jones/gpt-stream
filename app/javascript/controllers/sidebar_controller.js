// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["panel"]

    connect() {
        // Hide sidebar by default on mobile
        if (window.innerWidth < 768) {
            this.close()
        }

        window.addEventListener("resize", this.handleResize.bind(this))
    }

    disconnect() {
        window.removeEventListener("resize", this.handleResize.bind(this))
    }

    handleResize() {
        if (window.innerWidth >= 768) {
            this.open()
        } else {
            this.close()
        }
    }

    toggle() {
        if (this.element.classList.contains("hidden") ||
            this.element.classList.contains("-translate-x-full")) {
            this.open()
        } else {
            this.close()
        }
    }

    open() {
        this.element.classList.remove("hidden", "-translate-x-full")
    }

    close() {
        if (window.innerWidth < 768) {
            this.element.classList.add("-translate-x-full")
        }
    }
}
