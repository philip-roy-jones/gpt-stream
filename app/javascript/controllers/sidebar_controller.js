// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

const scrollPositions = {}

export default class extends Controller {
    static targets = ["panel"]

    connect() {
        // Hide sidebar by default on mobile
        if (window.innerWidth < 768) {
            this.close()
        }

        window.addEventListener("resize", this.handleResize.bind(this))

        document.addEventListener("turbo:before-render", this.storeScroll)
        document.addEventListener("turbo:render", this.restoreScroll)
    }

    disconnect() {
        window.removeEventListener("resize", this.handleResize.bind(this))
        document.removeEventListener("turbo:before-render", this.storeScroll)
        document.removeEventListener("turbo:render", this.restoreScroll)
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

    storeScroll() {
        document.querySelectorAll("[data-turbo-keep-scroll]").forEach((el) => {
            if (el.id) {
                scrollPositions[el.id] = el.scrollTop
            }
        })
    }

    restoreScroll() {
        document.querySelectorAll("[data-turbo-keep-scroll]").forEach((el) => {
            if (el.id && scrollPositions[el.id] !== undefined) {
                el.scrollTop = scrollPositions[el.id]
            }
        })
    }
}
