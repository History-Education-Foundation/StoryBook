class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :journal_entries, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_one_attached :profile_pic
  has_one_attached :bio_audio
end
