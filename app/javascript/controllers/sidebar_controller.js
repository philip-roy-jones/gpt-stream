// app/javascript/controllers/sidebar_controller.js
import {Controller} from "@hotwired/stimulus"

const scrollPositions = {}

export default class extends Controller {
    static targets = ["chatList"]

    connect() {
        document.addEventListener("turbo:before-render", this.storeScroll)
        document.addEventListener("turbo:render", this.restoreScroll)

        this.updateActive()
        document.addEventListener("turbo:load", this.updateActive)
        document.addEventListener("turbo:render", this.updateActive)
    }

    disconnect() {
        document.removeEventListener("turbo:before-render", this.storeScroll)
        document.removeEventListener("turbo:render", this.restoreScroll)

        document.removeEventListener("turbo:load", this.updateActive)
        document.removeEventListener("turbo:render", this.updateActive)
    }

    storeScroll = () => {
        document.querySelectorAll("[data-turbo-keep-scroll]").forEach((el) => {
            if (el.id) {
                scrollPositions[el.id] = el.scrollTop
            }
        })
    }

    restoreScroll = () => {
        document.querySelectorAll("[data-turbo-keep-scroll]").forEach((el) => {
            if (el.id && scrollPositions[el.id] !== undefined) {
                el.scrollTop = scrollPositions[el.id]
            }
        })
    }

    updateActive = () => {
        const container =
            this.element.querySelector('[data-sidebar-target="chatList"]') ||
            document.getElementById("sidebar-scroll")

        if (!container) return

        const path = window.location.pathname
        container.querySelectorAll("a[href]").forEach((a) => {
            const url = new URL(a.href, window.location.origin)
            const isActive = url.pathname === path
            a.classList.toggle("active", isActive)
            a.setAttribute("aria-current", isActive ? "page" : "")
        })
    }
}
