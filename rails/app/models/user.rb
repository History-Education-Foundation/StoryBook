class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :saved_books, dependent: :destroy
  has_many :saved_books_library, through: :saved_books, source: :book

  has_one_attached :profile_pic
  has_one_attached :bio_audio

  ROLES = ["admin", "staff", "student"].freeze

  after_initialize do
    self.role ||= "staff"
  end

  def admin?
    role == "admin"
  end

  def staff?
    role == "staff"
  end

  def student?
    role == "student"
  before_create :generate_api_token

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
