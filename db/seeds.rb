# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

User.find_or_create_by!(email: 'kody@llamapress.ai') do |user|
  user.password = '123456'
  user.password_confirmation = '123456'
end

# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

staff_user = User.find_by(email: 'kody@llamapress.ai')

# Remove any previous version of this specific test book for idempotency.
if staff_user
  book = staff_user.books.where(title: 'History of Labour Day').first
  book.destroy if book

  book = staff_user.books.create!(
    title: 'History of Labour Day',
    learning_outcome: 'Understand the origins and global significance of Labour Day.',
    reading_level: 'Intermediate',
    status: 'Published'
  )

  origins = book.chapters.create!(
    title: 'Origins',
    description: 'The beginnings of Labour Day and its historical context.'
  )

  origins.pages.create!(content: 'Labour Day, also known as International Workers’ Day, traces its origins to the labour union movement, especially the eight-hour workday campaign. The first May Day celebrations focused on the struggle of working people to improve their conditions in the late 19th century.')

  modern = book.chapters.create!(
    title: 'Modern Celebrations',
    description: 'How Labour Day is observed today around the world.'
  )

  modern.pages.create!(content: 'Today, Labour Day is recognized in over 80 countries. It is a public holiday in many nations, marked by parades, demonstrations, and celebrations to honor workers’ rights and achievements.')
end
