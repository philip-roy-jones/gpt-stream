import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        document.addEventListener("turbo:before-stream-render", this.updateUrl)
    }

    disconnect() {
        document.removeEventListener("turbo:before-fetch-response", this.updateUrl)
    }

    updateUrl = (event) => {
        const updater = document.getElementById('url_updater')
        if (updater && updater.dataset.url) {
            console.log(`Updating URL to: ${updater.dataset.url}`)
            history.pushState({}, '', updater.dataset.url)
            updater.remove() // Remove after using
        }
    }
}
