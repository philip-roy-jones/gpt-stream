import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.observer = new MutationObserver(this.onMutations.bind(this))
        this.observer.observe(this.element, { childList: true })
    }

    disconnect() {
        if (this.observer) this.observer.disconnect()
    }

    onMutations(mutations) {
        for (const m of mutations) {
            for (const node of m.addedNodes) {
                if (!(node instanceof HTMLElement)) continue
                const url = node.dataset && node.dataset.pushUrl
                if (url) {
                    history.pushState({}, "", url)
                    node.remove() // clean up the helper element
                }
            }
        }
    }
}