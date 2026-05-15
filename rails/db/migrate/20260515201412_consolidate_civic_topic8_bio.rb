class ConsolidateCivicTopic8Bio < ActiveRecord::Migration[7.2]
  def up
    # Use find_by name instead of ID for better portability across environments
    topic = CivicTopic.find_by(name: "American Civics Renewal Act")
    return unless topic

    full_bio = <<~TEXT
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

    topic.update!(
      bio_heading: "American Civics Renewal Act",
      bio: full_bio,
      contributions: nil,
      main_ideas: nil,
      legacy: nil,
      criticism: nil,
      suggested_reading: nil,
      publications: nil,
      contributions_heading: nil,
      main_ideas_heading: nil,
      legacy_heading: nil,
      criticism_heading: nil,
      suggested_reading_heading: nil,
      publications_heading: nil,
      quote: nil,
      quote_author: nil
    )
  end

  def down
  end
end
