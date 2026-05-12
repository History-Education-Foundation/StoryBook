# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.find_or_create_by!(email: 'kody@llamapress.ai') do |user|
  user.password = 'kody123'
  user.password_confirmation = 'kody123'
end

staff_user = User.find_by(email: 'kody@llamapress.ai')

# Remove any previous version of this specific test book for idempotency.
if staff_user
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
    tagline: "The architect of the 'Gingrich Revolution' and modern political polarization.",
    bio_heading: "The Early Ambition",
    bio: "As a politician, Newt Gingrich would say, “I grew up in kind of an idyllic children’s background.” But really, he grew up above a gas station in a life that was “narrow and harsh and unforgiving” (Packer 18). He got his first taste of leadership at ten, when he tried to convince the Parks Department to build a zoo for Harrisburg, making the front page. His ambition became more serious when he visited the scarred battlefields of Verdun and saw what bad leaders could do to a country. With Lincoln and Churchill as his models, he decided that “his future was in politics” (19).",
    contributions_heading: "Political Strategy & Innovation",
    contributions: "Politics as War: Transformed the House of Representatives from a deliberative body into a partisan battlefield.\nMedia Mastery: Baited Speakers of the House on C-SPAN until they were red in the face, using the new medium to reach voters directly.\nThe New South: Captured the emerging Republican majority by blending militarism, technology, and anti-tax sentiment.",
    main_ideas_heading: "The Gingrich Rhetoric",
    main_ideas: "The Corrupt Elite: A rhetorical weapon used to delegitimize any institution standing in his way.\nThe Welfare State Critique: Framed liberal policies not just as inefficient, but as morally corrupt.\nFamily Values Rhetoric: Used traditional morality as a political tool even while his personal life was in turmoil.",
    legacy_heading: "Historical Impact",
    legacy: "Gingrich's tactics in the late 70s and 80s laid the groundwork for the hyper-polarized American political landscape of the 21st century. By framing his opponents not just as wrong, but as a 'corrupt, left-wing machine,' he changed the rules of political engagement forever."
  },
  {
    name: "Peter Thiel",
    tagline: "The venture capitalist who redefined the relationship between technology and politics.",
    bio_heading: "The Logical Mindset",
    bio: "Peter Thiel grew up playing chess and memorizing geography. As his family moved between countries, he attended seven different elementary schools and had nearly no friends until he approached his teens (Packer 120). He hated the strictness of his teachers, but got near-perfect scores. When his family moved to the San Francisco Bay Area, he was thrust into the underfunded California school system (121). He coped with the chaos of uncontrollable classrooms by obsessing over his grades (122).",
    contributions_heading: "Technological & Financial Milestones",
    contributions: "PayPal: Co-founded the payment system with the goal of freeing people from government finance policy.\nPalantir: Created a massive data-analysis company that became a key tool for U.S. intelligence agencies.\nEarly Facebook Investment: Provided the first outside funding for Mark Zuckerberg, later earning $1.5 billion.",
    main_ideas_heading: "Economic & Philosophical Theories",
    main_ideas: "Zero to One: The belief that true innovation comes from creating something entirely new, rather than incremental improvement.\nLibertarian Idealism: The hope that technology could bypass the restrictions of modern democratic governments.\nTechnological Stagnation: A critique that humanity has stopped making major breakthroughs in the 'world of atoms' (energy, transport).",
    legacy_heading: "Influence & Legacy",
    legacy: "Thiel remains one of the most influential and controversial figures in Silicon Valley, acting as a bridge between the tech world and the new right-wing political movements."
  },
  {
    name: "The Edward Snowden Controversy",
    tagline: "A 7th Grade Guide to Understanding the Debate on Digital Privacy and Security",
    bio_heading: "Who is Edward Snowden?",
    bio: "Edward Snowden is a former contractor for the United States National Security Agency (NSA). In 2013, he leaked thousands of secret government documents to journalists, revealing how the U.S. government was collecting massive amounts of information from people’s phone calls, emails, and online activity.",
    contributions_heading: "What Did Snowden Reveal?",
    contributions: "The NSA was collecting information from millions of ordinary people—including people who were not suspected of any crime.\nThis collection included phone records, emails, chat messages, and even people’s internet searches.\nU.S. allies, like Germany and France, were also being spied on.",
    main_ideas_heading: "Why is This Controversial?",
    main_ideas: "Some People Call Him a Hero: They say Snowden revealed important information the public deserved to know. He started a conversation about privacy, freedom, and government power.\nOthers Call Him a Traitor: They argue he broke the law and endangered national security. They believe his actions made it harder for security agencies to protect the country.",
    legacy_heading: "What Happened Afterward?",
    legacy: "Snowden left the U.S. and now lives in Russia, because he fears being arrested.\nThe government changed some surveillance laws after the leaks to better protect privacy.\nThe world is still debating how to balance security and personal privacy.",
    suggested_reading_heading: "Class Discussion",
    suggested_reading: "Should the government be able to collect information to keep us safe? Why or why not?\nWas it right or wrong for Snowden to leak the information? Explain your opinion.\nHow much privacy should we expect when we use phones and the internet?",
    publications: "Edward Snowden Discussing\nEdward Snowden Speaking in 2013\nEdward Snowden at Meeting 2013\nEdward Snowden on video link",
    publications_heading: "Gallery Captions"
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
  # Ensure we clear out old fields that are no longer in the data
  controversy.update!(
    tagline: nil, bio_heading: nil, bio: nil, 
    contributions_heading: nil, contributions: nil, 
    main_ideas_heading: nil, main_ideas: nil, 
    legacy_heading: nil, legacy: nil, 
    suggested_reading_heading: nil, suggested_reading: nil,
    publications_heading: nil, publications: nil,
    criticism: nil, quote: nil, quote_author: nil
  )
  controversy.update!(data)
end
puts "Controversies seeded."
