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
      { content: 'These groups often meet in churches or meeting halls and debated issues facing the community.' }
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
    image_filename: "newt_gingrich.jpg",
    bio_heading: "Newt Gingrich",
    bio: "As a politician, Newt Gingrich would say, “I grew up in kind of an idyllic children’s background.” But really, he grew up above a gas station in a life that was “narrow and harsh and unforgiving” (Packer 18). He got his first taste of leadership at ten, when he tried to convince the Parks Department to build a zoo for Harrisburg, making the front page. His ambition became more serious when he visited the scarred battlefields of Verdun and saw what bad leaders could do to a country. With Lincoln and Churchill as his models, he decided that “his future was in politics” (19).\n\nNewt Gingrich married Jackie Battley when he was nineteen. While she worked, he went to Tulane for his Ph.D. and became a campus activist. When Tulane banned two films, Gingrich organized protests against the decision. “He had a favorite phrase, ‘corrupt elite,’ that could be hurled in any direction, and for the rest of his life, he kept it in his pocket” (20).\n\nWhile teaching college history, Gingrich ran for Congress in 1974 and 1976, losing both times. In 1978, he ran again. “He didn’t make racial appeals, didn’t seem very religious.” He understood the New South, where his love for aircraft carriers, moon launches, and personal computers was a perfect fit for the emerging Republican majority. With stagflation and a president preaching sacrifice, people were sour, suspicious of bureaucracies, and antitax. Gingrich’s opponent was a wealthy, liberal, female state senator. He knew exactly what to do. He moved to the right and went after her on welfare and taxes with his new pocket phrase, “the corrupt liberal welfare state.” Meanwhile, he talked about family values and featured Jackie and their kids in his ads. Though he was cheating on Jackie and they would soon divorce, Gingrich was elected to Congress in 1978 (21).\n\nIn Congress, Gingrich developed another phrase to keep in his pocket, “corrupt, left-wing machine.” He baited Speakers of the House until they were red in the face. He understood that politics was war, and he was the general. By 1994, he led the 'Contract with America' and became Speaker of the House, changing American politics forever.\n\nWork Cited: The Unwinding: An Inner History of the New America, by George Packer. Published by Farrar, Straus and Giroux, 2014.",
    quote: nil,
    quote_author: nil
  },
  {
    name: "Peter Thiel",
    tagline: "The venture capitalist who redefined the relationship between technology and politics.",
    image_filename: "peter_thiel.jpg",
    bio_heading: "Peter Thiel",
    bio: "Peter Thiel grew up playing chess and memorizing geography. As his family moved between countries, he attended seven different elementary schools and had nearly no friends until he approached his teens (Packer 120). He hated the strictness of his teachers, but got near-perfect scores. When his family moved to the San Francisco Bay Area, he was thrust into the underfunded California school system (121). He coped with the chaos of uncontrollable classrooms by obsessing over his grades (122). Like a certain set of high-achieving boys, he was into Tolkien, Sci-Fi, math, and computers, along with the libertarianism that this logic-based mindset cultivated (123). Thiel graduated high school as valedictorian, feeling “very optimistic.” He had no specific ambition, simply “to somehow have an impact on the world” (124).\n\nAt Stanford, Thiel made friends by debating theories of property late into the night (124). He co-founded The Stanford Review to push back against the university, which was moving to the left (125). He went on to practice law and then finance for a few years, but found the engineered competitiveness pointless (127). Thiel moved back to California and the region that had become known as Silicon Valley. He started his own hedge fund and befriended Max Levchin (131). Together, they created Confinity, which used PayPal to transfer money between Palm Pilot devices (132). Confinity grew to a million users, and Thiel hoped it would further his libertarian ideals by freeing people from government finance policy (133). Just before the dot-com bubble burst, he secured a round of funding and merged with Elon Musk’s X.com payment company (134). The company survived and, when sold, made Thiel $55 million (135).\n\nThiel’s friend Hoffman founded LinkedIn after the PayPal sale, through which he connected Thiel to Mark Zuckerberg and Thefacebook. In 2004, Thiel invested $500,000 into Thefacebook, later earning him $1.5 billion (210). The same year, Thiel cofounded Palantir, which analyzed data to help governments track down terrorists and would later be valued at $2.5 billion. Thiel was becoming “one of the world’s most successful technology investors,” and his new fund, Clarium Capital, skyrocketed (211). He rented mansions and bought racecars, though he often continued to wear T-shirts (213).\n\nIn 2008, just after moving the Clarium offices to Manhattan to be closer to Wall Street, the financial markets collapsed. “With everyone else in a panic, Thiel tried to catch a falling knife, but this time contrarianism became his enemy.” He had predicted a housing crash for years, yet timed his response disastrously, buying before stocks fell, and selling before they rose. He lost money and his investors pulled out. Clarium moved back to San Francisco. To Thiel’s credit, “he took losing well and kept an even keel with his staff.” However, “his view of America began to darken” (215).\n\nIn 2009, Thiel saw the last four decades as two steps forward and two steps back, but with key institutions eroding the entire time (381). Looking back, he was unimpressed with computer innovation, pointing to the iPhone and saying, “I don’t consider this to be a technological breakthrough” (383). He believed progress in finance and computers came from the lack of regulation (386). He gave $2.6 million to Ron Paul’s Super PAC, and smaller amounts to other causes. “But more and more he wanted to get away from politics, a highly inefficient way to bring about change” (387).\n\nThiel refused to submit to what he called “the ideology of the inevitability of the death of every individual” (388). He approached death as a problem to be solved, and, in 2010, invested in Halcyon, a startup working to sequence the human genome. Aside from health, he also invested in AI, space exploration, and independent city-states on the ocean (390). He disliked the inequality of privately-funded elementary schools and saw the value of higher education as dubious because it lacked entrepreneurial training (392-393). He started the Thiel Fellowships: grants given to young people to forgo college and start their own tech businesses. He prioritized those that would attract serious talent (394). Always, he was looking for something with a scope grand enough to end the tech-slowdown (395). He was no longer a hedge fund titan, but he was becoming “the intellectual provocateur he had dreamed of being at Stanford” (386).\n\nWork Cited: The Unwinding: An Inner History of the New America, by George Packer. Published by Farrar, Straus and Giroux, 2014.",
    quote: nil,
    quote_author: nil
  },
  {
    name: "The Edward Snowden Controversy",
    tagline: "A 7th Grade Guide to Understanding the Debate on Digital Privacy and Security",
    image_filename: "edward_snowden.jpg",
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
    criticism: nil, quote: nil, quote_author: nil, image_filename: nil
  )
  controversy.update!(data)
end
puts "Controversies seeded."

# Seed: Concepts
[
  {
    name: "Progressivism",
    tagline: "A political and social philosophy that advocates for reform and improvement in society through government action and scientific progress.",
    bio: "Detailed content coming soon...",
    bio_heading: "Overview",
    main_ideas: "Detailed content coming soon...",
    main_ideas_heading: "Main Ideas",
    legacy: "Detailed content coming soon...",
    legacy_heading: "Legacy"
  },
  {
    name: "Fascism",
    tagline: "A far-right, authoritarian ultranationalist political ideology characterized by dictatorial power and forcible suppression of opposition.",
    bio: "Detailed content coming soon...",
    bio_heading: "Overview",
    main_ideas: "Detailed content coming soon...",
    main_ideas_heading: "Main Ideas",
    legacy: "Detailed content coming soon...",
    legacy_heading: "Legacy"
  },
  {
    name: "Theocracy",
    tagline: "A form of government in which a deity is recognized as the supreme ruling authority, giving guidance to human intermediaries.",
    bio: "Detailed content coming soon...",
    bio_heading: "Overview",
    main_ideas: "Detailed content coming soon...",
    main_ideas_heading: "Main Ideas",
    legacy: "Detailed content coming soon...",
    legacy_heading: "Legacy"
  },
  {
    name: "Communism",
    tagline: "A socio-economic ideology and movement whose ultimate goal is the establishment of a communist society with common ownership of the means of production.",
    bio: "Detailed content coming soon...",
    bio_heading: "Overview",
    main_ideas: "Detailed content coming soon...",
    main_ideas_heading: "Main Ideas",
    legacy: "Detailed content coming soon...",
    legacy_heading: "Legacy"
  },
  {
    name: "Homo Deus",
    tagline: "A concept exploring the future of humanity, focusing on how humans might use technology to achieve god-like abilities.",
    bio: "Detailed content coming soon...",
    bio_heading: "Overview",
    main_ideas: "Detailed content coming soon...",
    main_ideas_heading: "Main Ideas",
    legacy: "Detailed content coming soon...",
    legacy_heading: "Legacy"
  }
].each do |data|
  concept = Concept.find_or_create_by!(name: data[:name])
  concept.update!(data)
end
puts "Concepts seeded."
