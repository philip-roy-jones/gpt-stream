// javascript
// File: `app/javascript/controllers/sidebar_controller.js`
import {Controller} from "@hotwired/stimulus"

const scrollPositions = {}

export default class extends Controller {
    static targets = ["chatList"]

    connect() {
        document.addEventListener("turbo:before-render", this.storeScroll)
        document.addEventListener("turbo:render", this.restoreScroll)
        document.addEventListener("turbo:load", this.updateActive)

        // Re-observe container after Turbo updates
        document.addEventListener("turbo:render", this.observeContainer)

        // Create observer and start observing current container
        this.observer = new MutationObserver(this.handleMutations)
        this.mutationDebounce = null
        this.observeContainer()
    }

    disconnect() {
        document.removeEventListener("turbo:before-render", this.storeScroll)
        document.removeEventListener("turbo:render", this.restoreScroll)
        document.removeEventListener("turbo:load", this.updateActive)
        document.removeEventListener("turbo:render", this.observeContainer)

        if (this.observer) {
            this.observer.disconnect()
            this.observer = null
        }
        if (this.mutationDebounce) {
            clearTimeout(this.mutationDebounce)
            this.mutationDebounce = null
        }
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

    // Called when mutations are observed
    handleMutations = (mutations) => {
        for (const m of mutations) {
            if (m.addedNodes && m.addedNodes.length > 0) {
                // Debounce to avoid multiple rapid calls
                if (this.mutationDebounce) clearTimeout(this.mutationDebounce)
                this.mutationDebounce = setTimeout(() => {
                    this.updateActive()
                    this.mutationDebounce = null
                }, 50)
                break
            }
        }
    }

    // Ensure the observer is attached to the current sidebar container
    observeContainer = () => {
        if (!this.observer) return

        // Disconnect first to avoid duplicate observers
        this.observer.disconnect()

        const container =
            (this.hasChatListTarget && this.chatListTarget) ||
            document.getElementById("sidebar-scroll")

        if (container) {
            // Watch for nodes being added anywhere under the container
            this.observer.observe(container, { childList: true, subtree: true })
        }
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
