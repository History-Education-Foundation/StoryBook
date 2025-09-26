# Script to create a book, chapters, and pages about the era of McCarthyism and the Red Scare

user = User.first

book = Book.create!(
  title: "McCarthyism and the Red Scare: Lessons from History",
  learning_outcome: "To understand the causes, impact, and legacy of McCarthyism and the Red Scare in the United States during the Cold War.",
  reading_level: "General",
  user: user,
  status: "Published"
)

chapters = [
  {
    title: "Chapter 1: The Origins of Fear",
    description: "Background on the rise of anti-communist sentiment in the U.S.",
    pages: [
      {content: "World War II ended with shifting global alliances. The Soviet Union emerged as a new rival, sparking anxiety over communism's spread."},
      {content: "American life was shaped by deep fears—of infiltration, espionage, and ideological subversion."},
      {content: "Government rhetoric, movies, and popular media amplified public terror, making suspicion a national habit."}
    ]
  },
  {
    title: "Chapter 2: McCarthy's Rise and the Witch Hunts",
    description: "How Senator Joseph McCarthy became the face of anti-communist crusades.",
    pages: [
      {content: "Senator Joseph McCarthy claimed he had a list of communists in the government, igniting media frenzy in 1950."},
      {content: "Hearings and investigations blacklisted federal employees, actors, and writers—even without evidence."},
      {content: "The phrase 'McCarthyism' came to mean reckless accusation and guilt by association."}
    ]
  },
  {
    title: "Chapter 3: Lives Ruined, Rights Denied",
    description: "Personal stories and the legal impact of anti-communist hysteria.",
    pages: [
      {content: "Thousands lost jobs and reputations. Loyalty oaths and surveillance became normal."},
      {content: "The Hollywood Ten were jailed for refusing to answer questions about their beliefs."},
      {content: "Many Americans became fearful of speaking their minds, damaging democracy itself."}
    ]
  },
  {
    title: "Chapter 4: The Collapse of McCarthyism",
    description: "The downfall of McCarthy and restoration of public reason.",
    pages: [
      {content: "Televised Army-McCarthy hearings exposed his tactics. The Senate condemned him in 1954."},
      {content: "Courageous journalists and everyday citizens challenged the fear-based culture."},
      {content: "Americans began reckoning with the costs of fear and the need for due process."}
    ]
  },
  {
    title: "Chapter 5: Lessons for Today",
    description: "What we must remember—and never repeat.",
    pages: [
      {content: "Fear can undermine justice, civil liberties, and free expression."},
      {content: "Unchecked power and public panic lead to real harm—even in democracies."},
      {content: "Vigilance, critical thinking, and empathy are necessary to protect freedom for all."}
    ]
  }
]

chapters.each do |ch|
  chapter = book.chapters.create!(title: ch[:title], description: ch[:description])
  ch[:pages].each do |page_attrs|
    chapter.pages.create!(content: page_attrs[:content])
  end
end

puts "Book, chapters, and pages for McCarthyism and the Red Scare created."