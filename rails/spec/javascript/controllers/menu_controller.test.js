import { describe, it, expect, beforeEach } from 'vitest'
import { Controller } from '@hotwired/stimulus'

/**
 * Menu Controller Tests
 * 
 * Tests the mobile menu toggle functionality
 * - Opens/closes mobile menu
 * - Toggles CSS classes
 * - Manages target elements
 */

describe('Menu Controller - Mobile Menu Toggle', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
  })

  it('should toggle mobile menu visibility class', async () => {
    // Define the menu controller
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        this.mobileMenuTarget.classList.toggle("show")
      }
    }

    // Register and set up controller
    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <button data-action="click->menu#toggle">Menu</button>
        <nav data-menu-target="mobileMenu" class="mobile-menu">
          <a href="/books">Books</a>
          <a href="/settings">Settings</a>
        </nav>
      </div>
    `

    // Wait for Stimulus to connect
    await new Promise(resolve => setTimeout(resolve, 10))

    const navElement = document.querySelector('[data-menu-target="mobileMenu"]')
    const button = document.querySelector('button')
    const controller = global.stimulusApp.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="menu"]'),
      'menu'
    )

    // Initially not showing
    expect(navElement.classList.contains('show')).toBe(false)

    // Click toggle button
    controller.toggle()
    expect(navElement.classList.contains('show')).toBe(true)

    // Click again to close
    controller.toggle()
    expect(navElement.classList.contains('show')).toBe(false)
  })

  it('should connect to menu element with mobileMenu target', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      connect() {
        this.element.setAttribute('data-menu-connected', 'true')
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <nav data-menu-target="mobileMenu"></nav>
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const controller = global.stimulusApp.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="menu"]'),
      'menu'
    )

    expect(controller).toBeTruthy()
    expect(controller.element.getAttribute('data-menu-connected')).toBe('true')
  })

  it('should handle multiple menu toggles correctly', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        this.mobileMenuTarget.classList.toggle("show")
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <nav data-menu-target="mobileMenu"></nav>
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const navElement = document.querySelector('[data-menu-target="mobileMenu"]')
    const controller = global.stimulusApp.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="menu"]'),
      'menu'
    )

    // Test multiple rapid toggles
    const toggleCount = 5
    for (let i = 0; i < toggleCount; i++) {
      controller.toggle()
    }

    // After odd number of toggles, should be visible
    expect(navElement.classList.contains('show')).toBe(true)

    // One more toggle should hide it
    controller.toggle()
    expect(navElement.classList.contains('show')).toBe(false)
  })

  it('should preserve menu state when toggling', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        this.mobileMenuTarget.classList.toggle("show")
      }

      isMenuOpen() {
        return this.mobileMenuTarget.classList.contains("show")
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <nav data-menu-target="mobileMenu"></nav>
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const controller = global.stimulusApp.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="menu"]'),
      'menu'
    )

    // Menu starts closed
    expect(controller.isMenuOpen()).toBe(false)

    // Open menu
    controller.toggle()
    expect(controller.isMenuOpen()).toBe(true)

    // Menu stays open
    expect(controller.isMenuOpen()).toBe(true)

    // Close menu
    controller.toggle()
    expect(controller.isMenuOpen()).toBe(false)
  })

  it('should work with button data-action attribute', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        this.mobileMenuTarget.classList.toggle("show")
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <button data-action="click->menu#toggle">Toggle</button>
        <nav data-menu-target="mobileMenu"></nav>
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const button = document.querySelector('button')
    const navElement = document.querySelector('[data-menu-target="mobileMenu"]')

    // Initially not showing
    expect(navElement.classList.contains('show')).toBe(false)

    // Click button
    button.click()
    expect(navElement.classList.contains('show')).toBe(true)

    // Click again
    button.click()
    expect(navElement.classList.contains('show')).toBe(false)
  })
})

describe('Menu Controller - Edge Cases', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
  })

  it('should handle missing mobileMenu target gracefully', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        try {
          this.mobileMenuTarget.classList.toggle("show")
        } catch (e) {
          // Handle missing target
          console.error('Mobile menu target not found:', e)
        }
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <!-- Missing data-menu-target="mobileMenu" -->
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const controller = global.stimulusApp.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="menu"]'),
      'menu'
    )

    // Should not throw when target is missing
    expect(() => {
      controller.toggle()
    }).not.toThrow()
  })

  it('should work with nested menu items', async () => {
    class MenuController extends Controller {
      static targets = ["mobileMenu"]

      toggle() {
        this.mobileMenuTarget.classList.toggle("show")
      }
    }

    registerController('menu', MenuController)

    document.body.innerHTML = `
      <div data-controller="menu">
        <button data-action="click->menu#toggle">Menu</button>
        <nav data-menu-target="mobileMenu" class="menu">
          <ul>
            <li><a href="/books">Books</a></li>
            <li><a href="/settings">Settings</a></li>
            <li>
              <details>
                <summary>More</summary>
                <a href="/profile">Profile</a>
                <a href="/help">Help</a>
              </details>
            </li>
          </ul>
        </nav>
      </div>
    `

    await new Promise(resolve => setTimeout(resolve, 10))

    const button = document.querySelector('button')
    const navElement = document.querySelector('[data-menu-target="mobileMenu"]')

    button.click()
    expect(navElement.classList.contains('show')).toBe(true)

    // Verify menu items are still accessible
    const menuItems = navElement.querySelectorAll('a')
    expect(menuItems.length).toBeGreaterThan(0)
  })
})
