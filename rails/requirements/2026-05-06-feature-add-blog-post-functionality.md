**Observation:**
On /posts

**Selected Element:**
<a class="hover:text-primary transition-colors element-selector-highlight" href="/posts">Blog posts</a>

**User Story:**
As a logged-in user, I want to be able to be able to add blog posts so that I can share my thoughts with the community.

**Current Behavior:**
The blog index page displays existing posts but lacks an option for users to create new content. The PostsController does not implement new or create actions.

**Desired Behavior:**
A "New Post" button is visible to logged-in users on the /posts page. Clicking this button opens a form to enter a title and body. Submitting the form creates a new post associated with the logged-in user.

**Verification Criteria (UI/UX):**
- [ ] Given I am logged in, When I visit /posts, Then I see a "New Post" button.
- [ ] Given I am not logged in, When I visit /posts, Then I do not see the "New Post" button.
- [ ] Given I am on the new post form, When I fill in the title and body and click "Create Post", Then the post is saved and I am redirected to the index.
- [ ] Given a new post is created, When I view the blog index, Then it appears at the top of the list.

**Business Rules:**
- [ ] Only authenticated users can access the post creation flow — Source: User said "when I am logged in..."
- [ ] New posts must be automatically associated with the current user — Source: Database schema (posts.user_id)

**Metadata:**
- **Category:** Feature - New Flow
- **Severity:** Medium
- **Environment:** /posts
- **Points:** 3 — *Reason:* Touches Model (assignment), Controller (new actions), View (new form + button), and Routes.

---

### Demo Path (Step-by-Step Verification)

1. **Given** I am a logged-in user, **When** I visit `/posts`, **Then** I see a "New Post" button at the top of the grid.
2. **When** I click "New Post", **Then** I am redirected to `/posts/new` showing a form with Title and Body.
3. **When** I fill in "My First Post" and "Content goes here" and click "Create Post", **Then** I am redirected back to `/posts`.
4. **Then** I see "My First Post" at the top of the blog list with my name as the author.

---

### Scope

**In Scope:**
- Updating `config/routes.rb` to allow `:new` and `:create` for posts.
- Adding `new` and `create` actions to `PostsController`.
- Adding `before_action :authenticate_user!` for creation actions.
- Creating `app/views/posts/new.html.erb` and `app/views/posts/_form.html.erb`.
- Adding the "New Post" button to `app/views/posts/index.html.erb` for authenticated users.

**Non-Goals:**
- Editing or deleting existing posts.
- Adding category/author selection (these remain optional/null for now unless existing logic dictates otherwise).
- Complex Rich Text editor (plain text area is the MVP).

---

### Implementation Notes

- **Routes:** Modify `resources :posts, only: [:index, :show]` to include `:new, :create`.
- **Controller:** 
    - Use `current_user.posts.build(post_params)` in `create`.
    - Redirect to `posts_path` or `post_path(@post)` with a success flash message.
- **Views:**
    - Use the existing Tailwind aesthetic from `index.html.erb`.
    - The `_form.html.erb` should use standard Rails form helpers.
- **Authentication:** Ensure `Devise` helpers like `user_signed_in?` and `authenticate_user!` are used correctly.

---

### Test Plan

**Models changed:** `Post` (no changes needed, but will test association)

**Test Strategy:**
- **Request specs** will verify the security gating (guests redirected to login) and the successful creation flow.

| Ticket Type | Primary Test | Secondary Test |
|-------------|--------------|----------------|
| Controller/API changes | Request spec | Model spec |

**Existing Specs to Update:**
- [ ] `spec/requests/posts_spec.rb` — Add tests for GET `/posts/new` and POST `/posts`.

**New Specs to Write:**
- [ ] `spec/requests/posts_spec.rb` — Test that unauthenticated users are redirected when trying to create a post.
- [ ] `spec/requests/posts_spec.rb` — Test that authenticated users can create a post and it correctly assigns `user_id`.

**Run These Specific Specs:**
```bash
RAILS_ENV=test bundle exec rspec spec/requests/posts_spec.rb
```
