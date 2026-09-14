import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    dismissible: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }
  
  connect() {
    // Open on connect if specified
    if (this.element.hasAttribute('data-modal-open')) {
      this.open()
    }
  }
  
  open() {
    const dialog = this.dialogTarget || this.element
    dialog.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
    this.bindEvents()
  }
  
  close() {
    const dialog = this.dialogTarget || this.element
    dialog.classList.add('hidden')
    document.body.style.overflow = ''
    this.unbindEvents()
  }
  
  toggle() {
    if (this.element.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }
  
  bindEvents() {
    if (this.closeOnEscapeValue) {
      document.addEventListener('keydown', this.handleKeydown)
    }
    if (this.dismissibleValue) {
      this.element.addEventListener('click', this.handleClickOutside)
    }
  }
  
  unbindEvents() {
    document.removeEventListener('keydown', this.handleKeydown)
    this.element.removeEventListener('click', this.handleClickOutside)
  }
  
  handleKeydown = (e) => {
    if (e.key === 'Escape') {
      this.close()
    }
  }
  
  handleClickOutside = (e) => {
    if (e.target === this.element) {
      this.close()
    }
  }
}
