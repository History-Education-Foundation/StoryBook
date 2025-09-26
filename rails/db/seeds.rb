# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

User.find_or_create_by!(email: 'kody@llamapress.ai') do |user|
  user.password = 'kody123'
  user.password_confirmation = 'kody123'
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

# Seed: Early England Colonies, 1700-1776
existing_title = 'Early England Colonies: Foundations of American Government'
if staff_user.books.find_by(title: existing_title)
  staff_user.books.where(title: existing_title).destroy_all
end
book = staff_user.books.create!(
  title: existing_title,
  learning_outcome: 'Explain how self-government developed in the English colonies before the American Revolution.',
  reading_level: '8th Grade',
  status: 'Draft'
)

chapters = [
  {
    title: 'Life in the Early Colonies',
    description: 'Everyday experience in the colonies during the 1700s.',
    pages: [
      { content: 'Starting in the 1600s, English people sailed across the Atlantic to build new communities. By the early 1700s, thirteen main colonies lined the east coast of North America.' },
      { content: 'Daily life in the colonies was hard. Most people were farmers, growing their own food and making what they needed.' },
      { content: 'Colonies were separated into three regions: New England, Middle, and Southern Colonies. Each region developed different economies and lifestyles.' }
    ]
  },
  {
    title: 'The Rise of Colonial Assemblies',
    description: 'How colonists began voting and governing themselves.',
    pages: [
      { content: 'At first, English governors and company leaders made most decisions in the colonies.' },
      { content: 'Soon, colonists wanted more of a say in their laws. Town meetings and assemblies began to form.' },
      { content: 'By the mid-1700s, most colonies had some form of representative assembly that created local laws and taxes.' },
      { content: 'These groups often met in churches or meeting halls and debated issues facing the community.' }
    ]
  },
  {
    title: 'The House of Burgesses and Virginia’s Legacy',
    description: 'The first elected assembly in America and its model for others.',
    pages: [
      { content: 'The Virginia House of Burgesses was established in 1619. It was the first elected lawmaking body in the colonies.' },
      { content: 'Members were elected by free, landowning men. They made laws and decisions about local life.' },
      { content: 'The House of Burgesses showed other colonies that people could govern themselves instead of relying on a king.' }
    ]
  },
  {
    title: 'Local Government and Town Meetings',
    description: 'How small communities practiced democracy.',
    pages: [
      { content: 'In New England colonies, people gathered in town meetings to discuss issues and make rules.' },
      { content: 'Everyone could speak, but only certain men could vote.' },
      { content: 'Town meetings taught colonists how to debate and compromise—skills important for democracy.' }
    ]
  },
  {
    title: 'Seeds of Independence',
    description: 'How colonial government led to revolution.',
    pages: [
      { content: 'By the 1700s, colonists had lots of practice running their own governments.' },
      { content: 'British laws and taxes started to anger colonists, who were used to making their own decisions.' },
      { content: 'Representative assemblies and town meetings helped unite people against British rule.' },
      { content: 'By 1776, the colonies were ready to declare independence and form a new nation.' }
    ]
  }
]
chapters.each do |ch|
  chapter = book.chapters.create!(title: ch[:title], description: ch[:description])
  ch[:pages].each do |page_attrs|
    chapter.pages.create!(content: page_attrs[:content])
  end
end
puts "Early England Colonies book seeded."
