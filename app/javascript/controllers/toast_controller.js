// javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["message"];
    static values = { duration: Number };

    connect() {
        this.durationValue = this.durationValue || 4000;
        this.messageTargets.forEach((el) => this.show(el));
    }

    show(el) {
        // ensure starting state
        el.classList.remove("toast--hide");

        // Add auto-dismiss timer
        el.dismissTimer = setTimeout(() => {
            this.closeElement(el);
        }, this.durationValue);

        // pointer drag to dismiss
        let startY = null;
        let currentY = 0;
        const onPointerDown = (e) => {
            // ignore pointerstart on interactive elements so clicks (like the close button) still fire
            if (e.target.closest('button, a, input, textarea, select, [role="button"], [data-action]')) {
                return;
            }
            startY = e.clientY;
            el.setPointerCapture?.(e.pointerId);
            el.style.transition = "none";
            el.addEventListener("pointermove", onPointerMove);
            el.addEventListener("pointerup", onPointerUp, { once: true });
            el.addEventListener("pointercancel", onPointerUp, { once: true });
        };
        const onPointerMove = (e) => {
            if (startY === null) return;
            currentY = e.clientY - startY;
            el.style.transform = `translateY(${currentY}px)`;
            el.style.opacity = `${Math.max(0, 1 - Math.abs(currentY) / 120)}`;
        };
        const onPointerUp = () => {
            el.removeEventListener("pointermove", onPointerMove);
            el.style.transition = "";
            if (Math.abs(currentY) > 60) {
                // dismiss
                this.closeElement(el, true);
            } else {
                // reset
                el.style.transform = "";
                el.style.opacity = "";
            }
            startY = null;
            currentY = 0;
        };

        el.addEventListener("pointerdown", onPointerDown, { passive: true });
        // store listeners to clear on removal
        el._toastListeners = { onPointerDown };
    }

    close(event) {
        // called by close button
        const el = event.currentTarget.closest(".toast");
        if (el) this.closeElement(el);
    }

    closeElement(el, fast = false) {
        clearTimeout(el.dismissTimer);
        el.classList.add("toast--hide");
        // quick removal after transition
        const delay = fast ? 120 : 240;
        setTimeout(() => {
            // remove element from DOM
            if (el._toastListeners?.onPointerDown) {
                el.removeEventListener("pointerdown", el._toastListeners.onPointerDown);
            }
            el.remove();
        }, delay);
    }
}
