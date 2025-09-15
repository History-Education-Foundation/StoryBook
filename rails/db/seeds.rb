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
  # Remove any previous version of this specific test book for idempotency.
  [
    'History of Labour Day',
    'The Life and Art of Vincent van Gogh'
  ].each do |t|
    b = staff_user.books.where(title: t).first
    b.destroy if b
  end

  # Existing book example (labour day) retained for context
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

  # Van Gogh book and content
  vangogh = staff_user.books.create!(
    title: 'The Life and Art of Vincent van Gogh',
    learning_outcome: 'Explore the remarkable life and masterpieces of Van Gogh, understanding his artistic evolution and impact.',
    reading_level: 'Intermediate',
    status: 'Draft'
  )
  early = vangogh.chapters.create!(
    title: 'Early Life',
    description: 'Discover Vincent van Gogh’s upbringing and personal struggles.'
  )
  early.pages.create!(content: "Vincent van Gogh was born in 1853 in Groot-Zundert, the Netherlands. His early years were marked by frequent relocations and a constant search for meaning in religion and art.")
  artjourney = vangogh.chapters.create!(
    title: 'Artistic Journey',
    description: 'Tracing Van Gogh’s growth as an artist and his search for style.'
  )
  artjourney.pages.create!(content: "Though Van Gogh's art was little known during his lifetime, his use of bold color and emotional honesty set him apart. From dark, moody paintings like 'The Potato Eaters' to luminous masterpieces in France, his work evolved rapidly.")
  legacy = vangogh.chapters.create!(
    title: 'Legacy and Influence',
    description: 'Assessing the profound influence Van Gogh left on modern art.'
  )
  legacy.pages.create!(content: "After a life filled with passion and suffering, Van Gogh died in 1890. Today, he is recognized as a pioneer of modern art, with works celebrated worldwide for their color, movement, and emotion.")
end
