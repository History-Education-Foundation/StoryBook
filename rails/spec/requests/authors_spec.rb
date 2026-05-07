require 'rails_helper'

RSpec.describe "Admin::Authors", type: :request do
  let(:admin) { User.create!(email: "admin_author@example.com", password: "password", role: "admin") }
  let(:author) { Author.create!(name: "Jane Doe", bio: "A great writer.") }

  describe "POST /admin/authors" do
    before { sign_in admin }

    context "with valid parameters" do
      it "creates a new Author and responds with turbo_stream" do
        expect {
          post admin_authors_path, params: { author: { name: "New Author", bio: "Bio here" } }, as: :turbo_stream
        }.to change(Author, :count).by(1)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include("turbo-stream")
        expect(response.body).to include("prepend")
        expect(response.body).to include("authors")
      end
    end
  end

  describe "PATCH /admin/authors/:id" do
    before { sign_in admin }

    it "updates the author and responds with turbo_stream" do
      patch admin_author_path(author), params: { author: { name: "Updated Name" } }, as: :turbo_stream
      expect(author.reload.name).to eq "Updated Name"
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("replace")
    end
  end

  describe "DELETE /admin/authors/:id" do
    before { sign_in admin }

    it "destroys the author and responds with turbo_stream" do
      author_to_delete = Author.create!(name: "Delete Me")
      expect {
        delete admin_author_path(author_to_delete), as: :turbo_stream
      }.to change(Author, :count).by(-1)
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("remove")
    end
  end
end
