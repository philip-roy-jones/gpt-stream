import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        document.addEventListener('turbo:render', this.updateUrl)
    }

    disconnect() {
        document.removeEventListener('turbo:render', this.updateUrl)
    }

    updateUrl = () => {
        const updater = document.getElementById('url_updater')
        if (updater && updater.dataset.url) {
            history.pushState({}, '', updater.dataset.url)
            updater.remove() // Remove after using
        }
    }
}
