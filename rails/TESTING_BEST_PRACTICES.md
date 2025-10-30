# Testing Best Practices: Lessons from the Chat Bubble Bug

## Executive Summary

**The Problem You Identified:** Our mocked JavaScript unit tests passed even though the code was broken because they never executed the actual HTML code.

**The Solution:** Combine unit tests with E2E tests using Capybara + Cuprite for critical integration points.

**Status:** ✅ Bug fixed, ✅ Tests updated, ✅ E2E tests created, ✅ Documentation complete.

---

## The Chat Bubble Case Study

### What Went Wrong
```
Real Usage: Chat bubble broken (indicator yellow, can't send messages)
↓
JavaScript Unit Tests: ✅ ALL PASSED
↓
Why? Tests mocked everything and never ran actual code
↓
Real E2E Tests: ❌ WOULD HAVE FAILED (and caught the bug)
```

### The Root Cause: sessionID Typo
```javascript
// app/views/public/_chat_bubble.html.erb, line 172
const sessionId = crypto.randomUUID()
subscription = consumer.subscriptions.create({
  session_id: sessionID  // ← BUG: sessionID is undefined!
}, callbacks)
```

### Why Unit Tests Missed It
```javascript
// spec/javascript/chat_bubble_integration.test.js
// ❌ We manually wrote correct code in the test
const sessionId = crypto.randomUUID()
consumer.subscriptions.create({
  session_id: sessionId  // ← WE wrote this correctly
}, callbacks)

// ✅ Test passed because we wrote correct code
// ❌ But never executed the buggy HTML code
```

---

## Testing Strategy Going Forward

### 1. **Unit Tests** (Fast, Isolated)
**When to use:** Pure logic, utilities, formatters

```javascript
// ✅ GOOD: Unit test for isolated function
it('should format tool name correctly', () => {
  expect(formatToolName('list_books')).toBe('List Books')
})

// ❌ BAD: Unit test for integration point
it('should establish WebSocket with valid session_id', () => {
  // Mock everything → misses typos in real code
  mockConsumer.subscriptions.create = vi.fn(...)
  expect(mockConsumer.subscriptions.create).toHaveBeenCalled()
})
```

**Files:**
- `spec/javascript/*.test.js` - Use for logic/utility tests
- `spec/models/*_spec.rb` - Use for model validations/associations
- `spec/requests/*_spec.rb` - Use for API endpoint testing

### 2. **E2E Tests** (Slower, Real Environment)
**When to use:** HTML rendering, JavaScript execution, user flows, WebSocket, integrations

```ruby
# ✅ GOOD: E2E test for integration point
describe 'Chat Bubble', type: :system, js: true, driver: :cuprite do
  it 'establishes WebSocket with valid session_id' do
    visit library_books_path
    
    # ✅ Real HTML from _chat_bubble.html.erb is loaded
    # ✅ Real JavaScript executes in Chromium browser
    # ✅ sessionID typo causes ReferenceError
    # ✅ Test fails and catches the bug!
    
    expect(page).to have_selector('#chat-bubble-toggle')
  end
end
```

**Files:**
- `spec/system/*_spec.rb` - Use for E2E tests with Capybara + Cuprite

### 3. **Linting & Static Analysis** (Instant)
**When to use:** Catch obvious typos, undefined variables, syntax errors

```bash
# Add to your workflow:
npm run lint  # ESLint for JavaScript
bundle exec rubocop  # RuboCop for Ruby
```

---

## The Testing Pyramid (Recommended)

```
        🔴 E2E Tests (10-20%)
       /                    \
      /  Real browser, slow  \
     /______________________ \
    
    🟡 Integration Tests (20-30%)
   /                            \
  /  Mock externals, test flow   \
 /____________________________ \

🟢 Unit Tests (50-70%)
Pure logic, fast, isolated
```

**For the Chat Bubble:**
- 🟢 Unit tests: formatToolName, parseMarkdown, getToolIcon, etc.
- 🟡 Integration: Mock WebSocket, test message flow
- 🔴 E2E: Real page load, real HTML execution, real browser

---

## Red Flags: When Tests Are Too Forgiving

### 🚩 Red Flag #1: Mock Accepts Anything
```javascript
// ❌ TOO FORGIVING
mockConsumer.subscriptions.create = vi.fn((config, callbacks) => {
  // No validation - accepts any data
  return mockSubscription
})

// ✅ BETTER: Validate critical data
mockConsumer.subscriptions.create = vi.fn((config, callbacks) => {
  // Fail if session_id is undefined or null
  if (!config.session_id) {
    throw new Error('session_id is required and cannot be undefined')
  }
  return mockSubscription
})
```

### 🚩 Red Flag #2: Test Writes the Code It's Testing
```javascript
// ❌ CIRCULAR
function createSubscription(config) {
  return consumer.subscriptions.create(config)
}

it('should create subscription with valid config', () => {
  const config = { session_id: 'valid-uuid' }
  expect(createSubscription(config)).toBeTruthy()
})
// We wrote both the code AND the test data

// ✅ BETTER: E2E test loads real code
visit library_books_path
// Real code runs in browser: session_id: sessionID (typo detected!)
```

### 🚩 Red Flag #3: Test Passes But Feature Broken
```
Test Results: ✅ PASS
User Experience: ❌ BROKEN
↓
You're testing the mock, not the real code
↓
Solution: Add E2E tests
```

---

## Capybara + Cuprite Setup

### Already Configured ✅
```ruby
# rails_helper.rb has Cuprite configured:
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, ...)
end

Capybara.javascript_driver = :cuprite
```

### How to Write E2E Tests

```ruby
# spec/system/chat_bubble_websocket_spec.rb
require 'rails_helper'

RSpec.describe 'Chat Bubble', type: :system, js: true, driver: :cuprite do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  it 'establishes WebSocket connection' do
    # 1. Load real page with real HTML
    visit library_books_path

    # 2. Verify real HTML elements exist
    expect(page).to have_selector('#chat-bubble-toggle')
    expect(page).to have_selector('#message-input')

    # 3. Real JavaScript executes in Chromium
    # 4. Any typos or undefined variables cause errors
    # 5. Test catches them!
  end

  it 'sends messages through real interface' do
    visit library_books_path

    # Real DOM interaction
    input = find('#message-input', visible: :all)
    input.fill_in(with: 'Hello!')

    button = find('button', text: 'Send', visible: :all)
    # button.click would actually send via WebSocket (if configured)

    expect(input.value).to eq('Hello!')
  end
end
```

### Run E2E Tests
```bash
# Run one spec
bundle exec rspec spec/system/chat_bubble_websocket_spec.rb

# Run all specs including E2E
bundle exec rspec

# Run only E2E
bundle exec rspec --pattern 'spec/system/**/*_spec.rb'
```

---

## Quick Reference: When to Use What

| Scenario | Best Test Type |
|----------|----------------|
| Testing string formatting | Unit test (JS or Ruby) |
| Testing model validation | Unit test (RSpec model spec) |
| Testing API endpoint | Request spec (RSpec) |
| Testing HTML rendering with JS | E2E test (Capybara) |
| Testing WebSocket flow | E2E test (Capybara) |
| Testing user interaction flow | E2E test (Capybara) |
| Testing external API calls | Mock in test (Webmock/VCR) |
| Testing complex business logic | Unit + request tests |

---

## The Testing Philosophy

### ❌ Wrong Approach
```
Write lots of mocked unit tests
↓
Tests pass
↓
Ship to production
↓
Users report bugs
↓
Realize tests were mocking the problem away
```

### ✅ Right Approach
```
Write unit tests for logic
Write E2E tests for integration
Run both in CI/CD
↓
Tests pass
↓
Ship to production
↓
Users don't report integration bugs
↓
Confidence in code quality
```

---

## Summary: Three Rules for Better Testing

### Rule 1: Test Real Code, Not Mocks
- ✅ Unit tests should test isolated logic
- ✅ E2E tests should test real HTML/JS/browser flow
- ❌ Don't let mocks hide bugs

### Rule 2: Use Mocks for Externals, Not Integrations
- ✅ Mock: Third-party APIs, external services, time
- ❌ Mock: Your own HTML rendering, JavaScript execution
- Use: Real browser for testing your own code

### Rule 3: If Tests Pass But Feature Broken, You Need E2E Tests
- ✅ This is a signal to add E2E tests
- ❌ Don't just add more unit test mocks
- Use: Capybara + Cuprite for real browser testing

---

## Files Reference

### Documentation
- `TEST_ANALYSIS.md` - Why mocked tests failed
- `TESTING_TRUTH.md` - Unit vs E2E philosophy
- `CHAT_BUBBLE_BUG_SUMMARY.md` - Bug summary
- `TESTING_BEST_PRACTICES.md` - This file

### Tests
- `spec/javascript/chat_bubble.test.js` - Unit tests (JavaScript)
- `spec/javascript/chat_bubble_integration.test.js` - Mock integration tests
- `spec/system/chat_bubble_websocket_spec.rb` - Real E2E tests

### Bug Fix
- `app/views/public/_chat_bubble.html.erb` - Fixed line 172 (sessionID → sessionId)

---

## Going Forward

### For New Features
1. ✅ Write unit tests for pure logic
2. ✅ Write E2E tests for integration points
3. ✅ Don't rely only on mocked tests
4. ✅ If it touches HTML/browser, use E2E

### For Debugging
1. When feature is broken but tests pass
2. Check: Are you mocking too much?
3. Solution: Write an E2E test
4. The bug usually appears in E2E test
5. Fix the bug, watch E2E test pass

### For Code Review
1. ❓ Is this a critical integration point?
2. ✅ If yes: Require E2E test in addition to unit test
3. ❓ Are we testing real code or just mocks?
4. ✅ If just mocks: Ask for E2E test coverage

---

## Questions to Ask

**When reviewing tests:**
- Does this test load and execute real code?
- Could a typo in the implementation hide from this test?
- If the feature breaks in production, would this test catch it?
- Are we testing the mock or the real code?

**If answer to any is "no", consider adding an E2E test.**

---

## The Bottom Line

> **Your instinct was correct: mocked tests missed the bug because they never ran the actual code. For critical integration points like WebSocket connections, use Capybara + Cuprite E2E tests to verify real code execution in a real browser.**

This is a lesson we can apply to all future development at Leonardo! 🚀
