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

# 8th Grade U.S. History Seeds
[
  "Analyzing Columbus",
  "Industrialization",
  "Financial Scams"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, subject: "U.S. History", grade_level: "8th Grade")
  topic.update!(
    tagline: "Exploring #{name} in 8th Grade U.S. History.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    grade_level: "8th Grade",
    subject: "U.S. History"
  )
end

# Separation of Powers (ID 11)
sop = CivicTopic.find_or_initialize_by(id: 11)
sop.update!(
  name: "Separation of Powers",
  tagline: "(8th-grade reading level)\n\nHow the U.S. Government Prevents Any One Group From Becoming Too Powerful",
  bio: "The Founders of the United States were very careful when they created the government. They wanted to make sure that no single person or group could get too much power. To do this, they used an idea called Separation of Powers.",
  bio_heading: "Overview",
  main_ideas: "Step 1: Congress passes a law (Legislative).\nStep 2: The President vetoes it (Executive check on Legislative).\nStep 3: Congress overrides the veto (Legislative check on Executive).\nStep 4: The Supreme Court declares the law unconstitutional (Judicial check on Legislative/Executive).",
  main_ideas_heading: "How it works",
  criticism: "Members of Congress may hesitate to challenge a President of their own party to avoid political backlash.",
  criticism_heading: "The Challenge",
  published: true,
  grade_level: "8th Grade",
  subject: "U.S. History"
)

# 1st Amendment and the Flag (ID 12)
flag = CivicTopic.find_or_initialize_by(id: 12)
flag.update!(
  name: "1st Amendment and the Flag",
  tagline: "(8th-grade reading level)\n\nProtecting the freedoms of speech and expression",
  bio: "The First Amendment protects some of the most important rights in America, like freedom of speech and the press. But did you know it also protects how we use symbols, like the American flag?",
  bio_heading: "Overview",
  main_ideas: "Texas v. Johnson (1989): Flag burning is protected 'symbolic speech'.\nUnited States v. Eichman (1990): Struck down the Flag Protection Act.",
  main_ideas_heading: "Key Supreme Court Cases",
  criticism: "Flag burning is a powerful and controversial form of expression that continues to spark debate.",
  criticism_heading: "Flag Burning and the First Amendment",
  legacy: "Learning about cases like Texas v. Johnson helps us understand why freedom of speech is so important in a democracy.",
  legacy_heading: "Student Activity: The Debate",
  suggested_reading: "Should freedom of speech protect actions that offend many people?",
  suggested_reading_heading: "Reflection & Discussion Questions",
  quote: "In a democracy, civic reasoning means balancing rights with responsibilities.",
  quote_author: "First Amendment Principles",
  published: true,
  grade_level: "8th Grade",
  subject: "U.S. History",
  video_url: "https://www.youtube.com/embed/ZVZt613Jnqs?si=ijvyB6kF9A_Fz5pX"
)

# Andrew Yang (ID 32)
yang = CivicTopic.find_or_initialize_by(id: 32)
yang.update!(
  name: "Andrew Yang",
  bio_heading: "2020 Presidential Campaign",
  bio: "Andrew Yang emerged as a distinctive figure in the 2020 Democratic presidential campaign. His innovative ideas and bold strategies aimed to reshape American politics and address the challenges of modern society.",
  contributions_heading: "Key Facts",
  contributions: "Founded Venture for America in 2011\nRaised over $40 million in campaign contributions\nProposed Universal Basic Income of $1,000/month\nQualified for 7 Democratic debates\nSuspended campaign February 11, 2020",
  publications_heading: "Featured Book",
  publications: "The War on Normal People",
  published: true
)

# James Lindsay (ID 37)
lindsay = CivicTopic.find_or_initialize_by(id: 37)
lindsay.update!(
  name: "James Lindsay",
  tagline: "American author and Political Commentator.",
  bio_heading: "Biography",
  bio: "James Stephen Lindsay (b. 1979) is an American author most notably known for co-authoring the book Cynical Theories (2020) with Helen Pluckrose, a British author and cultural writer. Lindsay has gained notoriety for appearing on the Joe Rogan podcast “The Joe Rogan Experience” four times and for speaking at Turning Point USA’s 2022 AmericaFest conference.",
  main_ideas_heading: "Social Media Analysis",
  main_ideas: "Derogatory Language: Uses insults or labels instead of arguments. Reduces complex issues to name-calling (‘only an idiot would support that policy.’) Signals group loyalty rather than critical reasoning.\nStrawman Framing: Misrepresenting an opponent’s argument to make it easier to attack; replaces a nuanced position with an exaggerated one. Avoids engaging with the strongest version of the opposing argument (steel-manning).\nHyperbolic Claims: Uses deliberate exaggeration to intensify emotion. For example, claiming ‘thousands of wasps’ when finding a nest to emphasize scale.\nIn-Group & Out-Group Language: Used to separate people into categories, which can result in alienation, preferred treatment, and bullying. We often see this in politics with Democrats vs. Republicans.\nMeme Ambiguity (Plausible Deniability): Uses humor and ambiguity to spread political ideas while avoiding accountability. Allows the creator to deny intent or claim it was a joke.\nClaims Presented Without Evidence: When looking at media, it’s important to look for the holes. If something is being presented as fact without a source, it encourages the audience to skip independent research.",
  criticism_heading: "Ideological Focus",
  criticism: "Lindsay is particularly fond of denouncing “woke” ideologies, which include collectivism, queer identities, and liberal practices.",
  publications_heading: nil,
  publications: nil,
  published: true
)

# American Civics Renewal Act (ID 39) - Fixing typos
acra = CivicTopic.find_or_initialize_by(id: 39)
acra_bio = <<~TEXT
  As the United States approaches its 250th anniversary, civics education has experienced a surge of legislation and funding. 44 states have introduced legislation concerning the subject in 2026, and the Department of Education announced over $150 million in grants in 2025. However, this push for better education has often been centered around a conservative view of the country. The Education Department’s America 250 Civics Coalition, which will plan programming for the celebrations this year, is comprised of over 40 right-leaning organizations. The Democratic senator Andy Kim has introduced a bill that advances a more bipartisan or nonpartisan approach. The bill, the American Civics Renewal Act, was read twice in the Senate and is currently being referred to the Committee on Health, Education, Labor, and Pensions as of March 2026. The act, if passed, would be a step towards a more collaborative and effective learning environment for students across the nation.

  Central to the bill is the "Renewal Agenda," which authorizes $2 million to create a commission of eight members chosen by a mix of Republicans and Democrats to develop a proposed curriculum plan for students of all ages. This national model curriculum would be provided to schools online as a completely optional resource. The act emphasizes the importance of "Action Civics," a concept that encourages students to develop civic-minded engagement beyond traditional classroom instruction. This approach is backed by research suggesting that action civics can boost both civic knowledge and academic performance, potentially transforming educational outcomes for future generations.

  The legislation’s strategy hinges on Bipartisan Collaboration. By fostering cooperation between Republicans and Democrats, the National Archives, and the Smithsonian, the bill aims to find educational solutions that are palatable to both sides of the political divide. Senator Andy Kim argues that action civics is often the type of education that sticks with people and lingers the most, suggesting that hands-on engagement is key to fostering long-term civic responsibility.

  However, the bill faces controversy and pushback. Conservative critics, such as Stanley Kurtz, argue that action civics projects are nearly always leftist in nature and discourage individualism in favor of group decision-making. These critics further contend that group-based learning is inevitably influenced too greatly by teachers and lacks the rigor of abstract classroom instruction. In Texas, these concerns led to 2021 restrictions that banned some types of student communication with elected officials, resulting in the dissolution of many action civics projects. Despite these claims of inherent partisanship, reports from The 74 Million suggest that most action civics initiatives actually focus on local, non-partisan issues like bullying, youth vaping, or student newspapers.

  If successful, the American Civics Renewal Act would be a landmark policy, creating a national curriculum model where few currently exist. Lessons from the past—such as the 1990s curriculum standards debate and the 2010s Common Core movement—show that national programs often become bogged down in controversy. Yet, despite challenges like low civic literacy, the act represents a first step in creating a more productive, bipartisan conversation about the future of education in America.

  Work Cited:
  “American Civics Renewal Act.” Congress.gov, 119th Congress, 11 Mar. 2026, https://www.congress.gov/bill/119th-congress/senate-bill/4057/text
  Kurtz, Stanley. “Action Civics Replaces Citizenship with Partisanship.” The American Mind, 26 Jan. 2021, https://americanmind.org/memo/action-civics-replaces-citizenship-with-partisanship/
  Lehrer-Small, Asher. “Texas Guts ‘Woke Civics.’ Now Kids Can’t Engage in a Key Democratic Process.” The Guardian, 1 May 2023, https://www.theguardian.com/us-news/2023/may/01/texas-civics-students-democratic-participation
  Loveless, Tom. “The Curriculum Wars.” Hoover Institution, 21 Mar. 2014, https://www.hoover.org/research/curriculum-wars
  Schwartz, Sarah. “A New Bill Calls for a Model Civics Curriculum at a Polarized Moment.” Education Week, 18 Mar. 2026, https://www.edweek.org/teaching-learning/a-new-bill-calls-for-a-model-civics-curriculum-at-a-polarized-moment/2026/03
TEXT

acra.update!(
  name: "American Civics Renewal Act",
  bio_heading: "American Civics Renewal Act",
  bio: acra_bio,
  published: true
)

# Lobbying Lesson Plan (ID 40)
lobbying = CivicTopic.find_or_initialize_by(id: 40)
lobbying_content = <<~TEXT
  Hook
  Brief explanation of lobbying: Companies pay a team to talk to congresspeople to try to get them to pass laws that are favorable to the company. As a form of leverage, they may also work with the press or start an organization in a congressperson’s home state to convince voters not to elect the congressperson in the future.

  Student activity: Do you think lobbying is a form of free speech or legalized corruption? Stand up and move towards the left side of the room if you think lobbying is free speech, and move towards the right side of the room if you think lobbying is legalized corruption. If you’re pretty sure about your position, go all the way to the wall, but if you’re not as sure, stay closer to the middle of the room.

  Call on several students to explain why they chose to stand in their position.

  Have the students return to their seats.

  Lobbying Mini-Lesson
  The word “lobbyist” was originally used to describe people who waited in the lobby of Congress or of the President’s hotel to talk to them and try to change their mind about issues. Now, “lobbyist” more generally refers to any individual who spends a significant amount of time or money to influence the decisions of congresspeople or other government officials.

  Companies and industries can hire people to represent them as lobbyists, giving gifts and spending time with people in government to persuade them to vote on certain actions. Lobbyists in this way bring about change in laws. Lobbying is effective and has brought about change, and money can affect not only the quality of lobbyists, but it also more deeply determines the amount of sway these companies and professional interests can have.

  There are policies that try to stop insider trading and the monetization of professional relationships. This is achieved by having “cooling off periods” that prevent people who worked in public office (government positions) from immediately joining lobbying groups. This stops them from using inside information and capitalizing on relationships with government. Some lifelong bans also exist with looser restrictions that only apply to specific contracts or issues. However, lobbying is still criticized for existing at all, with many critics saying this practice is legalized corruption.

  As an example of Lobbying, let’s look at the National Potato Council, or NPC. The NPC as an organization represents potato growers and tries to secure better laws that will help protect them and control their income, as many of them are owned and controlled by just four companies. The NPC actively lobbies in Washington, and works off of public donations. While they are a special interest group, they fight against companies that try to keep control of prices and continue to make more at growers’ expenses. The NPC has also been criticized for lobbying for the classification of potatoes as vegetables in school lunch programs in order to increase demand, a classification that partially contradicts scientific nutrition principles.

  Textual Analysis
  Share the following anti-lobbying passage with students:

  Historically, scholars, practitioners, and even leaders of state expressed concerns over the ubiquitous role lobbying plays in influencing government officials (Mack, 1989; Silberfeld, 2006). Concerns over lobbying’s influence on government officials may be bolstered by a body of empirical research supporting the idea that firms’ lobbying can sway government officials to act in ways that benefit lobbying firms (Kaiser, 2010; Shaffer, 1995). 
  Connaughton discussed how quickly votes can change in Congress with the Private Securities Litigation Reform Act of 1995, a bill that would make it harder to prove securities fraud for Wall Street bankers. Connaughton was able to help convince President Clinton to veto the bill, but it was overruled in congress, even by Senator Ted Kennedy, who supported the veto at first: “Even Ted Kennedy, the great champion of civil rights and liberties, who has assured plaintiffs’ groups that he was with them, flipped and went along with the corporate coalition and voted to override Clinton’s veto” (Connaughton, 2012, Pg 101, 110). “Money is the basis of almost all relationships in DC…The rest of the country may be divided into red and blue, but DC is green (that is, covered in money), and cheerfully so” (Pg 11).

  Ask students to highlight or point out these three things in the above passage:
  Examples of influence or financial power
  Potential conflicts of interest
  Who may benefit from these systems

  Share the following pro-lobbying passage with students:

  “Lobbying is advocacy of a point of view, either by groups or individuals. A special interest is nothing more than an identified group expressing a point of view — be it colleges and universities, churches, charities, public interest or environmental groups, senior citizens organizations, even state, local or foreign governments. While most people think of lobbyists only as paid professionals, there are also many independent, volunteer lobbyists — all of whom are protected by the same First Amendment.”
  “Lobbying is a legitimate and necessary part of our democratic political process. Government decisions affect both people and organizations, and information must be provided in order to produce informed decisions. Public officials cannot make fair and informed decisions without considering information from a broad range of interested parties. All sides of an issue must be explored in order to produce equitable government policies.”

  From https://www.lobbyinginstitute.com/about

  Ask students to highlight or point out these three things in the above passage:
  Legal justification for lobbying
  How lobbying may be democratic
  How lobbying may improve decision-making

  Structured Academic Controversy
  Structured Question: On balance, does lobbying strengthen democracy?

  Instruct the students to form pairs. Give each pair a copy of the SAC handout PDF, which contains instructions for the debate activity. They will research both sides of the lobbying controversy, then join with another pair to form a group of 4. The pairs will each debate one side of the issue, then switch and debate the other side. After this, they will work as a group of 4 to come to a consensus about lobbying’s effect on Democracy.

  Synthesis
  Have the class reconvene to synthesize ideas through a teacher-facilitated discussion. Write their ideas down on the whiteboard using a T-chart or another form of visual organizer. What can students agree on? What additional evidence would help the class come to a consensus?

  Exit
  Have each student write their own short statement about lobbying’s effect on democracy based on the debate and discussion. They should mention at least one piece of evidence from each side to show that they understand the nuance of the issue.
TEXT

lobbying.update!(
  name: "Lobbying",
  bio: "Companies pay a team to talk to congresspeople to try to get them to pass laws that are favorable to the company. This lesson explores whether lobbying is a form of free speech or legalized corruption through a Structured Academic Controversy.",
  bio_heading: "Lesson Overview",
  criticism: lobbying_content,
  criticism_heading: "Structured Academic Controversy",
  published: true
)


puts "8th Grade U.S. History lesson plans seeded."

# 10th Grade World History Seeds
[
  "Chile in the Cold War",
  "The Pinochet File"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, grade_level: "10th Grade", subject: "World History")
  
  if name == "Chile in the Cold War"
    topic.update!(
      tagline: "Exploring Chile's struggle between competing ideologies during the Cold War.",
      bio: "Image: lesson_plans/chile_cold_war/intro.png\n\nObjectives: Students will analyze the 1973 Chilean coup through multiple historical lenses, identifying how political interests shape different narratives of the same event.\n\nEssential Question: How do power, perspective, and political interests shape the way history is told?\n\nContext: In 1970, Chile elected Salvador Allende, the first Marxist to become president of a Latin American country through open elections. His presidency and the subsequent 1973 military coup led by General Augusto Pinochet became a flashpoint of the Cold War, involving superpowers and competing ideologies.",
      legacy: "Image: lesson_plans/chile_cold_war/history_map_1.jpeg\n\nImage: lesson_plans/chile_cold_war/history_map_2.jpeg\n\nImage: lesson_plans/chile_cold_war/cold_war_concerns.svg\n\nPotential Starter Questions\n* What was the Cold War?\n* How did the U.S. and USSR compete for influence in Latin America?\n* What is the difference between a democracy and a dictatorship?\n\nImage: lesson_plans/chile_cold_war/allende_1.svg\nImage: lesson_plans/chile_cold_war/allende_2.svg\nImage: lesson_plans/chile_cold_war/allende_3.svg\n\nVideo: https://www.youtube.com/watch?v=sF5kczRhW9E",
      main_ideas: "Image: lesson_plans/chile_cold_war/why_overthrow.svg\n\nActivity: Memories of Santiago: watch 4:35-end\nVideo: https://www.youtube.com/watch?v=gw5YrRC6VE8\n\nImage: lesson_plans/chile_cold_war/slide_1.svg\nImage: lesson_plans/chile_cold_war/slide_2.svg\nImage: lesson_plans/chile_cold_war/slide_3.svg\n\nImage: lesson_plans/chile_cold_war/slide_4.svg\nImage: lesson_plans/chile_cold_war/slide_5.svg\nImage: lesson_plans/chile_cold_war/slide_6.svg\n\nImage: lesson_plans/chile_cold_war/slide_7.svg\nImage: lesson_plans/chile_cold_war/slide_8.svg\n\nVideo: https://www.youtube.com/watch?v=gOdP3VtXJvE\n\nVideo: https://www.youtube.com/watch?v=y9HjvHZfCUI",
      criticism: "Image: lesson_plans/chile_cold_war/appeal_to_un.svg\n\nUntold History (The Progressive Perspective):\n* Focuses on the CIA's role in destabilizing the Allende government through economic pressure and support for opposition groups.\n* Highlights the democratic legitimacy of Allende's election and his social reforms aimed at reducing inequality.\n* Emphasizes the brutal human rights abuses of the Pinochet regime, including the Caravans of Death and the Operation Condor.\n* Views the coup as an act of American imperialism intended to protect corporate interests and prevent the spread of socialism.\n\nImage: lesson_plans/chile_cold_war/slide_9.svg\nImage: lesson_plans/chile_cold_war/slide_10.svg\nImage: lesson_plans/chile_cold_war/slide_11.svg\n\nImage: lesson_plans/chile_cold_war/slide_12.svg\nImage: lesson_plans/chile_cold_war/slide_13.svg\nImage: lesson_plans/chile_cold_war/slide_14.svg\n\nImage: lesson_plans/chile_cold_war/slide_15.svg\nImage: lesson_plans/chile_cold_war/slide_16.svg\n\nUnhumans (The Counter-Revolutionary Perspective):\n* Argues that Allende was leading Chile toward a Soviet-aligned Marxist dictatorship and violating the constitution.\n* Highlights the severe economic chaos, hyperinflation, and food shortages caused by Allende's policies.\n* Views the military intervention as a necessary preventative action by the Chilean armed forces to save the country from civil war.\n* Emphasizes the economic 'Miracle of Chile' that followed, transforming the nation into a stable, market-oriented economy.",
      suggested_reading: "Image: lesson_plans/chile_cold_war/summary.svg\n\nWhat current events have multiple competing narratives explaining them? How can we use the skills we have learned to understand these events?",
      bio_heading: "Lesson Overview",
      legacy_heading: "The Cold War",
      main_ideas_heading: "The Overthrow",
      criticism_heading: "Two Narratives",
      published: true,
      is_lesson_plan: true
    )
  else
    topic.update!(
      tagline: "Exploring #{name} in 10th Grade World History.",
      bio: "Placeholder biography for #{name}. Content coming soon.",
      bio_heading: "Overview",
      published: true
    )
  end
end
puts "10th Grade World History lesson plans seeded."

# Financial Literacy Seeds
[
  "Credit",
  "Taxes & Retirement",
  "House Hacking"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name)
  topic.update!(
    tagline: "Exploring #{name} in Financial Literacy.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    grade_level: nil,
    subject: "Financial Literacy"
  )
end
puts "Financial Literacy lesson plans seeded."

# World Geography Seeds
[
  "Chile in the Cold War",
  "The Pinochet File"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, subject: "World Geography")
  topic.update!(
    tagline: "Exploring #{name} in World Geography.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    grade_level: nil,
    subject: "World Geography"
  )
end
puts "World Geography lesson plans seeded."

# Psychology Seeds
[
  "Biological",
  "Cognition",
  "Development & Learning",
  "Social & Personality",
  "Mental & Physical Health"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, subject: "Psychology")
  topic.update!(
    tagline: "Exploring #{name} in Psychology.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    is_lesson_plan: true,
    grade_level: nil,
    subject: "Psychology"
  )
end

# Add sub-topics for Social & Personality
parent = CivicTopic.find_by(name: "Social & Personality", subject: "Psychology")
if parent
  ["Deindividuation", "Social Influence"].each do |name|
    sub = CivicTopic.find_or_create_by!(name: name, parent: parent)
    sub.update!(
      subject: "Psychology",
      tagline: "Exploring #{name} under Social & Personality.",
      bio: "Placeholder biography for #{name}. Content coming soon.",
      bio_heading: "Overview",
      published: true,
      is_lesson_plan: true
    )
  end
end
puts "Psychology lesson plans seeded."

# Digital Literacy Seeds
[
  "Iran Monitoring Civilians"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, subject: "Digital Literacy")
  topic.update!(
    tagline: "Exploring #{name} in Digital Literacy.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    grade_level: nil,
    subject: "Digital Literacy"
  )
end
puts "Digital Literacy lesson plans seeded."

# Student Leaders Seeds
[
  "Praise in public",
  "Time is power"
].each do |name|
  topic = CivicTopic.find_or_create_by!(name: name, subject: "Student Leaders")
  topic.update!(
    tagline: "Exploring #{name} in Student Leaders.",
    bio: "Placeholder biography for #{name}. Content coming soon.",
    bio_heading: "Overview",
    published: true,
    grade_level: nil,
    subject: "Student Leaders"
  )
end
puts "Student Leaders lesson plans seeded."

puts "Civic Topics seeded."
