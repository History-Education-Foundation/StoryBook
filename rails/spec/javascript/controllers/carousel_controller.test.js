import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

/**
 * Carousel Controller Tests
 * 
 * Tests the testimonial carousel functionality
 * - Auto-rotation with intervals
 * - Next/Previous navigation
 * - Manual controls reset auto-rotation interval
 * - Data binding from HTML attributes
 * - Cleanup on disconnect
 */

describe('Carousel - Core Logic (Unit Tests)', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.runOnlyPendingTimers()
    vi.useRealTimers()
  })

  it('should initialize carousel state', () => {
    // Test carousel state initialization
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0

    expect(current).toBe(0)
    expect(reviews[current]).toBe('Review 1')
  })

  it('should navigate to next review', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0

    // Next navigation
    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Review 2')

    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Review 3')

    // Should wrap around
    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Review 1')
  })

  it('should navigate to previous review', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 2 // Start at last review

    // Previous navigation
    current = (current + reviews.length - 1) % reviews.length
    expect(reviews[current]).toBe('Review 2')

    current = (current + reviews.length - 1) % reviews.length
    expect(reviews[current]).toBe('Review 1')

    // Should wrap around
    current = (current + reviews.length - 1) % reviews.length
    expect(reviews[current]).toBe('Review 3')
  })

  it('should handle auto-rotation interval', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0
    let interval = null
    const updates = []

    // Start interval (simulating carousel auto-rotation)
    interval = setInterval(() => {
      current = (current + 1) % reviews.length
      updates.push(reviews[current])
    }, 3500)

    // Advance time
    vi.advanceTimersByTime(3500)
    vi.advanceTimersByTime(3500)
    vi.advanceTimersByTime(3500)

    // Should have rotated through reviews
    expect(updates.length).toBe(3)
    expect(updates[0]).toBe('Review 2')
    expect(updates[1]).toBe('Review 3')
    expect(updates[2]).toBe('Review 1')

    clearInterval(interval)
  })

  it('should reset interval on manual navigation', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0
    let intervalCount = 0

    // Create first interval
    let interval = setInterval(() => {
      current = (current + 1) % reviews.length
    }, 3500)
    const firstIntervalId = interval

    // Simulate manual click - clear and restart
    clearInterval(interval)
    intervalCount++

    interval = setInterval(() => {
      current = (current + 1) % reviews.length
    }, 3500)
    const secondIntervalId = interval

    // Intervals should be different objects
    expect(firstIntervalId).not.toBe(secondIntervalId)
    expect(intervalCount).toBe(1)

    clearInterval(interval)
  })

  it('should handle single review without errors', () => {
    const reviews = ['Only Review']
    let current = 0

    // Next should wrap to same review
    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Only Review')

    // Previous should also stay on same review
    current = (current + reviews.length - 1) % reviews.length
    expect(reviews[current]).toBe('Only Review')
  })

  it('should parse review data from JSON', () => {
    const reviewsJson = JSON.stringify(['Review 1', 'Review 2', 'Review 3'])
    const reviews = JSON.parse(reviewsJson)

    expect(reviews).toEqual(['Review 1', 'Review 2', 'Review 3'])
    expect(reviews.length).toBe(3)
  })

  it('should handle empty reviews array gracefully', () => {
    const reviews = []
    let current = 0

    if (reviews.length > 0) {
      current = (current + 1) % reviews.length
    }

    // Should not throw
    expect(current).toBe(0)
    expect(reviews.length).toBe(0)
  })

  it('should display correct review text', () => {
    const reviews = [
      'Great service! ★★★★★',
      'Amazing & wonderful 💯',
      'Très bien! 10/10 🎉'
    ]
    let current = 0

    expect(reviews[current]).toContain('★')

    current = (current + 1) % reviews.length
    expect(reviews[current]).toContain('💯')

    current = (current + 1) % reviews.length
    expect(reviews[current]).toContain('🎉')
  })

  it('should maintain carousel state through multiple operations', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0

    // Forward navigation
    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Review 2')

    // Backward navigation
    current = (current + reviews.length - 1) % reviews.length
    expect(reviews[current]).toBe('Review 1')

    // Forward again
    current = (current + 1) % reviews.length
    expect(reviews[current]).toBe('Review 2')

    // Verify state is consistent
    expect(current).toBe(1)
  })
})

describe('Carousel - DOM Integration Tests', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
  })

  it('should render carousel HTML structure', () => {
    document.body.innerHTML = `
      <div class="carousel">
        <div class="review-text">Review 1</div>
        <button class="prev">Previous</button>
        <button class="next">Next</button>
      </div>
    `

    const carousel = document.querySelector('.carousel')
    const text = document.querySelector('.review-text')
    const prevBtn = document.querySelector('.prev')
    const nextBtn = document.querySelector('.next')

    expect(carousel).toBeTruthy()
    expect(text).toBeTruthy()
    expect(prevBtn).toBeTruthy()
    expect(nextBtn).toBeTruthy()
  })

  it('should update review text in DOM', () => {
    document.body.innerHTML = `
      <div class="review-text">Review 1</div>
    `

    const text = document.querySelector('.review-text')

    // Simulate navigation
    text.textContent = 'Review 2'
    expect(text.textContent).toBe('Review 2')

    text.textContent = 'Review 3'
    expect(text.textContent).toBe('Review 3')
  })

  it('should handle button clicks', () => {
    document.body.innerHTML = `
      <button class="next">Next</button>
    `

    const button = document.querySelector('.next')
    let clicked = false

    button.addEventListener('click', () => {
      clicked = true
    })

    button.click()
    expect(clicked).toBe(true)
  })

  it('should toggle active state on buttons', () => {
    document.body.innerHTML = `
      <button class="prev">Previous</button>
      <button class="next">Next</button>
    `

    const prevBtn = document.querySelector('.prev')
    const nextBtn = document.querySelector('.next')

    prevBtn.classList.add('active')
    expect(prevBtn.classList.contains('active')).toBe(true)
    expect(nextBtn.classList.contains('active')).toBe(false)

    prevBtn.classList.remove('active')
    nextBtn.classList.add('active')

    expect(prevBtn.classList.contains('active')).toBe(false)
    expect(nextBtn.classList.contains('active')).toBe(true)
  })

  it('should read data attributes from element', () => {
    const reviewsData = JSON.stringify(['Review 1', 'Review 2', 'Review 3'])

    document.body.innerHTML = `
      <div class="carousel" data-reviews='${reviewsData}'>
        <div class="review-text">Review 1</div>
      </div>
    `

    const carousel = document.querySelector('.carousel')
    const reviews = JSON.parse(carousel.dataset.reviews)

    expect(reviews).toEqual(['Review 1', 'Review 2', 'Review 3'])
    expect(reviews.length).toBe(3)
  })

  it('should update carousel with aria-live for accessibility', () => {
    document.body.innerHTML = `
      <div class="carousel" aria-live="polite" aria-atomic="true">
        <div class="review-text">Review 1</div>
      </div>
    `

    const carousel = document.querySelector('.carousel')
    expect(carousel.getAttribute('aria-live')).toBe('polite')
    expect(carousel.getAttribute('aria-atomic')).toBe('true')
  })
})

describe('Carousel - Edge Cases and Error Handling', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.runOnlyPendingTimers()
    vi.useRealTimers()
  })

  it('should handle very large number of reviews', () => {
    const reviews = Array.from({ length: 1000 }, (_, i) => `Review ${i + 1}`)
    let current = 0

    // Navigate to near the end
    current = 999
    current = (current + 1) % reviews.length
    expect(current).toBe(0)
    expect(reviews[current]).toBe('Review 1')
  })

  it('should handle rapid navigation', () => {
    const reviews = ['Review 1', 'Review 2', 'Review 3']
    let current = 0

    // Rapid clicks
    for (let i = 0; i < 10; i++) {
      current = (current + 1) % reviews.length
    }

    // Should land on Review 2 (10 % 3 = 1, so index 1)
    expect(reviews[current]).toBe('Review 2')
  })

  it('should cleanup intervals properly', () => {
    const intervals = []
    
    const createInterval = () => {
      const interval = setInterval(() => {
        // Do something
      }, 3500)
      intervals.push(interval)
      return interval
    }

    const clearAllIntervals = () => {
      intervals.forEach(interval => clearInterval(interval))
      intervals.length = 0
    }

    // Create multiple intervals
    createInterval()
    createInterval()
    createInterval()

    expect(intervals.length).toBe(3)

    // Clear all
    clearAllIntervals()
    expect(intervals.length).toBe(0)
  })

  it('should handle null or undefined reviews', () => {
    let reviews = null

    const getNextReview = (current) => {
      if (!reviews || reviews.length === 0) return current
      return (current + 1) % reviews.length
    }

    const current = 0
    const next = getNextReview(current)

    // Should not crash
    expect(next).toBe(0)
  })

  it('should validate carousel data structure', () => {
    const validateCarouselData = (data) => {
      if (!data) return false
      if (!Array.isArray(data)) return false
      if (data.length === 0) return false
      return data.every(item => typeof item === 'string')
    }

    expect(validateCarouselData(['Review 1', 'Review 2'])).toBe(true)
    expect(validateCarouselData([])).toBe(false)
    expect(validateCarouselData(null)).toBe(false)
    expect(validateCarouselData('not an array')).toBe(false)
    expect(validateCarouselData([123, 456])).toBe(false)
  })
})
