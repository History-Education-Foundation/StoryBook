require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:books).dependent(:destroy) }
    it { should have_many(:saved_books).dependent(:destroy) }
    it { should have_many(:saved_books_library).through(:saved_books).source(:book) }
  end

  describe 'Devise authentication' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe 'ActiveStorage attachments' do
    it { should have_one_attached(:profile_pic) }
    it { should have_one_attached(:bio_audio) }
  end

  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe "role methods" do
    it "#admin? returns true for admin users" do
      user = create(:user, :admin_user)
      expect(user.admin?).to be_truthy
    end

    it "#admin? returns false for non-admin users" do
      user = create(:user, :staff)
      expect(user.admin?).to be_falsey
    end

    it "#staff? returns true for staff users" do
      user = create(:user, :staff)
      expect(user.staff?).to be_truthy
    end

    it "#staff? returns false for non-staff users" do
      user = create(:user, :student)
      expect(user.staff?).to be_falsey
    end

    it "#student? returns true for student users" do
      user = create(:user, :student)
      expect(user.student?).to be_truthy
    end

    it "#student? returns false for non-student users" do
      user = create(:user, :staff)
      expect(user.student?).to be_falsey
    end
  end

  describe "API token generation" do
    it "generates a unique API token on creation" do
      user = create(:user)
      expect(user.api_token).not_to be_nil
      expect(user.api_token.length).to eq(64) # 32 bytes hex = 64 characters
    end

    it "generates different tokens for different users" do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.api_token).not_to eq(user2.api_token)
    end

    it "persists the API token" do
      user = create(:user)
      token = user.api_token
      user.reload
      expect(user.api_token).to eq(token)
    end

    it 'generates an api_token before creation' do
      user = User.new(email: 'test@example.com', password: 'password123')
      expect(user.api_token).to be_nil
      user.save
      expect(user.api_token).to be_present
      expect(user.api_token.length).to eq(64) # 32 bytes hex = 64 characters
    end
  end

  describe "role initialization" do
    it "defaults to 'staff' role on initialize" do
      user = User.new
      expect(user.role).to eq("staff")
    end

    it "preserves assigned role on initialize" do
      user = User.new(role: "admin")
      expect(user.role).to eq("admin")
    end
  end

  describe "constants" do
    it "defines ROLES constant with valid roles" do
      expect(User::ROLES).to include("admin", "staff", "student")
    end
  end

  describe "user creation" do
    it "creates a valid user with required attributes" do
      user = create(:user)
      expect(user).to be_persisted
      expect(user.email).to be_present
      expect(user).to respond_to(:encrypted_password)
    end

    it "allows creating a user with all optional attributes" do
      user = create(:user, name: "John Doe", role: "admin", admin: true)
      expect(user.name).to eq("John Doe")
      expect(user.role).to eq("admin")
      expect(user.admin?).to be_truthy
    end

    it "cannot create a user without email" do
      user = build(:user, email: "")
      expect(user).not_to be_valid
    end

    it "cannot create a user with duplicate email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
    end
  end
end