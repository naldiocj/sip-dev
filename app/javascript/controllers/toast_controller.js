import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    autohide: { type: Boolean, default: true },
    duration: { type: Number, default: 5000 }
  }
  
  connect() {
    // Expose toast function globally
    window.showToast = (message, type = 'info', title = null) => {
      this.addToast(message, type, title)
    }
  }
  
  addToast(message, type = 'info', title = null) {
    const toast = this.createElement(type, title, message)
    this.containerTarget.appendChild(toast)
    
    // Auto remove
    if (this.autohideValue) {
      setTimeout(() => {
        this.removeToast(toast)
      }, this.durationValue)
    }
  }
  
  createElement(type, title, message) {
    const div = document.createElement('div')
    div.className = `fb-toast-${type} toast-enter`
    
    const icon = this.getIcon(type)
    const titleText = title || this.getDefaultTitle(type)
    
    div.innerHTML = `
      ${icon}
      <div class="flex-1 min-w-0">
        <p class="fb-toast-title">${titleText}</p>
        <p class="fb-toast-message">${message}</p>
      </div>
      <button type="button" class="fb-toast-close" onclick="this.closest('.fb-toast-${type}').remove()">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    
    // Click to dismiss
    div.addEventListener('click', (e) => {
      if (!e.target.closest('button')) {
        this.removeToast(div)
      }
    })
    
    return div
  }
  
  getIcon(type) {
    const icons = {
      success: `<svg class="fb-toast-icon text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
      error: `<svg class="fb-toast-icon text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
      warning: `<svg class="fb-toast-icon text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>`,
      info: `<svg class="fb-toast-icon text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`
    }
    return icons[type] || icons.info
  }
  
  getDefaultTitle(type) {
    const titles = {
      success: 'Sucesso',
      error: 'Erro',
      warning: 'Atenção',
      info: 'Informação'
    }
    return titles[type] || 'Notificação'
  }
  
  removeToast(toast) {
    toast.classList.remove('toast-enter')
    toast.classList.add('toast-exit')
    setTimeout(() => toast.remove(), 300)
  }
}
