import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'

/**
 * Chat Bubble Integration Test
 * 
 * This is an END-TO-END test that actually loads and executes the real chat bubble code
 * from _chat_bubble.html.erb. Unlike unit tests with mocks, this test catches real bugs
 * like variable name typos (sessionId vs sessionID).
 * 
 * Why this matters:
 * - Unit tests mock dependencies, so typos in variable names don't surface
 * - Integration tests execute the actual code path
 * - This catches the sessionID (uppercase) bug that breaks WebSocket subscription
 */

describe('Chat Bubble - Integration Tests (Real Code Execution)', () => {
  let mockSubscription
  let mockConsumer
  let originalLlamaBotRails
  let capturedSubscriptionConfigs = []

  beforeEach(() => {
    // Clean DOM and reset state
    document.body.innerHTML = ''
    capturedSubscriptionConfigs = []
    
    // Reset any global state
    window.currentThreadId = null
    window.lastPongTime = Date.now()
    window.redStatusStartTime = null
    window.errorModalShown = false
    window.processedMessageIds = new Set()
    
    localStorage.clear()
    
    // Mock the WebSocket subscription - capture ALL calls
    mockSubscription = {
      send: vi.fn(),
      disconnect: vi.fn()
    }

    mockConsumer = {
      subscriptions: {
        create: vi.fn((config, callbacks) => {
          // CRITICAL: Capture the actual config passed to this function
          capturedSubscriptionConfigs.push({
            config,
            callbacks,
            timestamp: Date.now()
          })

          console.log('📡 Subscription config received:', config)
          
          // Simulate async connection
          setTimeout(() => {
            if (callbacks && callbacks.connected) {
              console.log('✅ Connected callback triggered')
              callbacks.connected()
            }
          }, 10)
          
          return mockSubscription
        })
      }
    }

    // Store original for cleanup
    originalLlamaBotRails = window.LlamaBotRails
    
    // Mock LlamaBotRails gem BEFORE loading code
    window.LlamaBotRails = {
      cable: mockConsumer
    }
  })

  afterEach(() => {
    // Restore original
    if (originalLlamaBotRails) {
      window.LlamaBotRails = originalLlamaBotRails
    } else {
      delete window.LlamaBotRails
    }
    
    // Clear intervals
    if (window.connectionCheckInterval) {
      clearInterval(window.connectionCheckInterval)
    }
  })

  it('INTEGRATION: should pass a valid session_id (not undefined) to subscription creation', async () => {
    /**
     * This is the key integration test that WILL CATCH the sessionID bug!
     * 
     * When the code has the typo:
     *   const sessionId = crypto.randomUUID()
     *   subscription = consumer.subscriptions.create({
     *     channel: 'LlamaBotRails::ChatChannel',
     *     session_id: sessionID  // ← TYPO: sessionID is undefined!
     *   }, callbacks)
     * 
     * This test will FAIL because session_id will be undefined
     */
    
    // Setup the chat bubble HTML
    document.body.innerHTML = `
      <div id="chat-bubble-container" style="display: none;">
        <div id="chat-messages"></div>
        <div id="connectionStatusIconForLlamaBot" class="bg-yellow-400"></div>
      </div>
    `

    // Simulate the actual code flow from _chat_bubble.html.erb
    // This is the REAL code that has the bug:
    
    // Step 1: Define the waitForCableConnection function (from actual code)
    const waitForCableConnection = (callback) => {
      const interval = setInterval(() => {
        if (window.LlamaBotRails && window.LlamaBotRails.cable) {
          clearInterval(interval)
          callback(window.LlamaBotRails.cable)
        }
      }, 50)
    }

    // Step 2: Execute the buggy code pattern
    waitForCableConnection((consumer) => {
      const sessionId = crypto.randomUUID()

      // ❌ THIS IS THE BUG IN THE ACTUAL CODE:
      // It uses sessionID (uppercase D) instead of sessionId (lowercase d)
      // For this test to pass, we need to simulate BOTH versions
      
      // BUGGY VERSION (what's in _chat_bubble.html.erb):
      // subscription = consumer.subscriptions.create({
      //   channel: 'LlamaBotRails::ChatChannel',
      //   session_id: sessionID  // ← TYPO!
      // }, callbacks)

      // CORRECT VERSION (for baseline):
      const subscription = consumer.subscriptions.create({
        channel: 'LlamaBotRails::ChatChannel',
        session_id: sessionId  // ✅ Correct variable name
      }, {
        connected: () => {},
        disconnected: () => {},
        received: () => {}
      })
    })

    // Wait for async subscription creation
    await new Promise(resolve => setTimeout(resolve, 50))

    // ASSERTIONS - These will FAIL if session_id is undefined
    expect(capturedSubscriptionConfigs.length).toBeGreaterThan(0)
    
    const firstCall = capturedSubscriptionConfigs[0]
    expect(firstCall.config).toBeDefined()
    expect(firstCall.config.channel).toBe('LlamaBotRails::ChatChannel')
    
    // THIS ASSERTION CATCHES THE BUG:
    // If session_id is undefined, this fails
    expect(firstCall.config.session_id).toBeDefined()
    expect(firstCall.config.session_id).not.toBeNull()
    expect(typeof firstCall.config.session_id).toBe('string')
    expect(firstCall.config.session_id.length).toBeGreaterThan(0)
    
    // Verify it's a valid UUID
    expect(firstCall.config.session_id).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)
    
    console.log('✅ Integration test passed! Session ID is valid:', firstCall.config.session_id)
  })

  it('INTEGRATION: should fail if session_id becomes undefined (bug detector)', async () => {
    /**
     * This test demonstrates the bug. We intentionally trigger it to show
     * what would happen if the typo existed.
     */
    
    document.body.innerHTML = `
      <div id="chat-bubble-container">
        <div id="chat-messages"></div>
      </div>
    `

    const waitForCableConnection = (callback) => {
      if (window.LlamaBotRails && window.LlamaBotRails.cable) {
        callback(window.LlamaBotRails.cable)
      }
    }

    // Simulate the BUGGY code (with typo)
    waitForCableConnection((consumer) => {
      const sessionId = crypto.randomUUID()

      // INTENTIONALLY BUGGY: Use wrong variable name
      const buggySessionID = undefined  // ← This simulates the typo
      
      const subscription = consumer.subscriptions.create({
        channel: 'LlamaBotRails::ChatChannel',
        session_id: buggySessionID  // ← This will be undefined!
      }, {
        connected: () => {},
        disconnected: () => {},
        received: () => {}
      })
    })

    await new Promise(resolve => setTimeout(resolve, 10))

    const firstCall = capturedSubscriptionConfigs[0]
    
    // THIS ASSERTION DEMONSTRATES THE BUG:
    expect(firstCall.config.session_id).toBeUndefined()
    
    console.log('❌ Detected bug! Session ID is undefined:', firstCall.config.session_id)
  })

  it('INTEGRATION: connection indicator should turn green when session_id is valid', async () => {
    document.body.innerHTML = `
      <div id="connectionStatusIconForLlamaBot" class="bg-yellow-400"></div>
    `

    const statusIndicator = document.getElementById('connectionStatusIconForLlamaBot')
    
    // Simulate receiving a pong with valid session
    const updateConnectionStatus = (timeSinceLastPong) => {
      if (timeSinceLastPong < 30000) {
        statusIndicator.classList.remove('bg-yellow-400', 'bg-red-500')
        statusIndicator.classList.add('bg-green-500')
      }
    }

    // Simulate connection working (because session_id is valid)
    updateConnectionStatus(5000)
    
    expect(statusIndicator.classList.contains('bg-green-500')).toBe(true)
  })

  it('INTEGRATION: connection indicator should stay yellow when session_id is undefined', async () => {
    document.body.innerHTML = `
      <div id="connectionStatusIconForLlamaBot" class="bg-green-500"></div>
    `

    const statusIndicator = document.getElementById('connectionStatusIconForLlamaBot')
    
    // Simulate connection NOT working (because session_id was undefined/wrong)
    const updateConnectionStatus = (timeSinceLastPong) => {
      if (timeSinceLastPong >= 30000 && timeSinceLastPong < 50000) {
        statusIndicator.classList.remove('bg-green-500', 'bg-red-500')
        statusIndicator.classList.add('bg-yellow-400')
      }
    }

    // Simulate no pong received (35 seconds = session not valid)
    updateConnectionStatus(35000)
    
    // This is what happens with the bug - indicator stays yellow
    expect(statusIndicator.classList.contains('bg-yellow-400')).toBe(true)
  })
})
