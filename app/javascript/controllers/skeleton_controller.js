import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autohide: { type: Boolean, default: true },
    minDisplay: { type: Number, default: 500 }
  }
  
  connect() {
    // Hide skeleton after content loads
    if (this.autohideValue) {
      setTimeout(() => {
        this.hide()
      }, this.minDisplayValue)
    }
    
    // Listen for Turbo load complete
    document.addEventListener('turbo:load', () => {
      this.show()
    })
    
    document.addEventListener('turbo:loadend', () => {
      setTimeout(() => {
        this.hide()
      }, 300)
    })
  }
  
  show() {
    this.element.classList.remove('hidden')
  }
  
  hide() {
    this.element.classList.add('hidden')
  }
  
  toggle() {
    this.element.classList.toggle('hidden')
  }
}
