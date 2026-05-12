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
    reading_level: '9th Grade',
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
    reading_level: '10th Grade',
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

# Seed: Scholars
[
  { name: "Charles A. Beard", bio: "A pioneering American historian who focused on the economic and social factors influencing history, best known for 'An Economic Interpretation of the Constitution of the United States'." },
  { name: "James Loewen", bio: "An American sociologist, historian, and author, most noted for his 1995 book, 'Lies My Teacher Told Me: Everything Your American History Textbook Got Wrong'." },
  { name: "Ryan Knowles", bio: "A modern researcher in history education focusing on the intersection of social studies pedagogy and democratic civic engagement." },
  { name: "Peter Kuznick", bio: "A Professor of History and Director of the Nuclear Studies Institute at American University, co-author of 'The Untold History of the United States' with Oliver Stone." },
  { name: "Adam Przeworski", bio: "A prominent political scientist known for his work on democratic theory, political economy, and the relationship between economic development and democracy." },
  { name: "Howard Zinn", bio: "A historian, playwright, and social activist, best known for his influential book 'A People's History of the United States', which presents American history from the perspective of marginalized groups." },
  { name: "George Sylvester Counts", bio: "A leading educator and social theorist who advocated for schools to play a more active role in social reform and reconstruction during the Great Depression." }
].each do |scholar_data|
  scholar = Scholar.find_or_create_by!(name: scholar_data[:name])
  scholar.update!(bio: scholar_data[:bio])
end
puts "Scholars seeded with bios."

# Seed: Controversies
[
  {
    name: "Curtis Yarvin",
    tagline: "Influential neoreactionary thinker and software engineer.",
    bio: "Curtis Yarvin, also known by the pen name Mencius Moldbug, is an American political theorist and software engineer. He is a primary figure in the Neoreactionary movement (NRx), which critiques liberal democracy and advocates for a return to monarchical or corporate governance.",
    contributions: "Founded the Urbit project: A decentralized personal server platform.\nDeveloped the 'Moldbuggian' critique of modern democratic institutions.",
    main_ideas: "The Cathedral: A decentralized network of academics and journalists who enforce social norms.\nFormalism: The idea that political power should be clearly defined and formalized like property rights.",
    criticism: "Accused of promoting authoritarianism and elitism.\nCriticized for views on race and history that many find deeply problematic."
  },
  {
    name: "Newt Gingrich",
    tagline: "Former Speaker of the House and architect of the 'Contract with America'.",
    bio: "Newt Gingrich served as the 50th Speaker of the United States House of Representatives from 1995 to 1999. He led the Republican Revolution in 1994, ending 40 years of Democratic majority in the House.",
    contributions: "Contract with America: A legislative agenda that helped Republicans win the 1994 midterm elections.\nPlayed a key role in welfare reform and the first balanced federal budget in a generation.",
    main_ideas: "Partisan polarization: Advocates for a more confrontational style of politics.\nTechnological optimism: Frequently discusses how technology can transform government and society.",
    criticism: "Often blamed for the increased polarization and breakdown of civility in American politics.\nFaced ethics investigations during his time as Speaker."
  },
  {
    name: "Peter Thiel",
    tagline: "Billionaire entrepreneur, venture capitalist, and political donor.",
    bio: "Peter Thiel is a co-founder of PayPal, Palantir Technologies, and Founders Fund. He was the first outside investor in Facebook. He is known for his contrarian views on technology, education, and politics.",
    contributions: "The Thiel Fellowship: A program that pays students to drop out of college and start companies.\nZero to One: An influential book on startups and innovation.",
    main_ideas: "Stagnation: Argues that technological progress has slowed down outside of bits and software.\nLibertarianism: Has expressed skepticism about the compatibility of freedom and democracy.",
    criticism: "Criticized for his support of Donald Trump and other controversial political figures.\nControversy over his funding of the lawsuit that bankrupt Gawker Media."
  },
  {
    name: "Edward Snowden Controversy",
    tagline: "The debate over surveillance, whistleblowing, and national security.",
    bio: "In 2013, Edward Snowden, a former NSA contractor, leaked highly classified information about global surveillance programs. This sparked a worldwide debate on the balance between national security and individual privacy.",
    contributions: "Exposed PRISM and other mass surveillance programs.\nCatalyzed changes in how tech companies handle user data encryption.",
    main_ideas: "Right to Privacy: The belief that mass surveillance is a fundamental violation of human rights.\nTransparency: The argument that government activities should be open to public scrutiny.",
    criticism: "Accused of treason and endangering national security by the U.S. government.\nCritics argue that his leaks damaged intelligence gathering capabilities."
  },
  {
    name: "Pinochet",
    tagline: "The military dictatorship and economic transformation of Chile.",
    bio: "Augusto Pinochet was a general who led a military coup that overthrew the democratically elected government of Salvador Allende in Chile in 1973. He ruled as a dictator until 1990.",
    contributions: "Economic Liberalization: Implemented 'shock therapy' policies recommended by the Chicago Boys.\nConstitution of 1980: Established a framework that governed Chile for decades.",
    main_ideas: "Anti-communism: Justified his rule as necessary to prevent a Marxist takeover.\nFree Market Capitalism: Promoted deregulation, privatization, and foreign investment.",
    criticism: "Responsible for widespread human rights abuses, including thousands of executions, disappearances, and torture.\nCondemned globally for the suppression of democratic institutions and civil liberties."
  }
].each do |data|
  controversy = Controversy.find_or_create_by!(name: data[:name])
  controversy.update!(data)
end
puts "Controversies seeded."
