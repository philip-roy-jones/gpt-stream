import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        document.addEventListener("turbo:before-stream-render", this.afterStreamRender)
    }

    disconnect() {
        document.removeEventListener("turbo:before-stream-render", this.afterStreamRender)
    }

    afterStreamRender = (event) => {
        const originalRender = event.detail.render

        event.detail.render = async (streamElement) => {
            // Let Turbo do its thing first
            await originalRender(streamElement)

            // ✅ Now DOM changes are applied
            const urlUpdater = document.getElementById("url_updater")
            if (urlUpdater) {
                history.pushState({}, "", urlUpdater.dataset.url)
                urlUpdater.remove()
            }
        }
    }
}
