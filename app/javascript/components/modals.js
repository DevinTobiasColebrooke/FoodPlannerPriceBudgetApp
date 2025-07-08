// Modal Component
export class Modal {
    constructor(modalId, triggerId, closeId) {
        this.modal = document.getElementById(modalId);
        this.trigger = document.getElementById(triggerId);
        this.closeBtn = document.getElementById(closeId);
        
        if (this.modal && this.trigger && this.closeBtn) {
            this.init();
        }
    }

    init() {
        this.trigger.addEventListener('click', () => this.open());
        this.closeBtn.addEventListener('click', () => this.close());
        
        // Close modal if clicked outside the content
        this.modal.addEventListener('click', (event) => {
            if (event.target === this.modal) {
                this.close();
            }
        });

        // Handle keyboard events
        document.addEventListener('keydown', (event) => this.handleKeydown(event));
    }

    handleKeydown(event) {
        if (event.key === 'Escape' && !this.modal.classList.contains('hidden')) {
            this.close();
        }
    }

    open() {
        this.modal.classList.remove('hidden');
        this.trigger.setAttribute('aria-expanded', 'true');
    }

    close() {
        this.modal.classList.add('hidden');
        this.trigger.setAttribute('aria-expanded', 'false');
    }
} 