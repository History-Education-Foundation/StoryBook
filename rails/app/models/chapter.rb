class Chapter < ApplicationRecord
  belongs_to :book
  has_many :pages, dependent: :destroy
end
