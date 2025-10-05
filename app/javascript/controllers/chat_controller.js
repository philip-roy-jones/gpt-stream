// JavaScript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["list"]

    static values = {
        scrollThreshold: { type: Number, default: 100 },
        pushUrl: String
    }

    connect() {
        if (this.hasPushUrlValue && this.pushUrlValue) {
            history.pushState(null, "", this.pushUrlValue)
        }
        this.element.removeAttribute("data-chat-push-url-value")

        // Synchronous scroll to bottom before first paint
        const el = this.hasListTarget ? this.listTarget : this.element
        el.scrollTop = el.scrollHeight

        this.scrollToBottom()
        this.observer = new MutationObserver(() => this.scrollToBottom())
        const target = this.hasListTarget ? this.listTarget : this.element
        this.observer.observe(target, { childList: true, subtree: true })

        this._onTurboRender = () => this.scrollToBottom()
        document.addEventListener("turbo:before-stream-render", this._onTurboRender)
    }

    disconnect() {
        if (this.observer) this.observer.disconnect()
        document.removeEventListener("turbo:before-stream-render", this._onTurboRender)
    }

    isNearBottom() {
        const el = this.hasListTarget ? this.listTarget : this.element
        const threshold = this.scrollThresholdValue
        // Check if user is within threshold pixels of bottom
        return (el.scrollHeight - el.scrollTop - el.clientHeight) <= threshold
    }

    scrollToBottom() {
        const el = this.hasListTarget ? this.listTarget : this.element
        if (this.isNearBottom()) {
            requestAnimationFrame(() => {
                el.scrollTo({
                    top: el.scrollHeight,
                    behavior: "smooth"
                })
            })
        }
    }
}


