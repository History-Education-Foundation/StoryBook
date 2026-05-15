class ConsolidateCivicTopic10Bio < ActiveRecord::Migration[7.2]
  def up
    topic = CivicTopic.find_by(name: "Potential context for Utah’s 1st Congressional District (CD1) Race")
    return unless topic

    full_bio = <<~TEXT
      As a tax-exempt non-profit, The History Education Foundation does not endorse political candidates. However, as an organization committed to historical analysis and civic literacy, we believe it is appropriate to provide context that helps voters critically evaluate political events.

      Our founder has personal relationships with both Nate Blouin and Ben McAdams, including volunteering for McAdams’ 2018 campaign. These relationships are grounded in respect. At the same time, it is important to examine broader structural forces shaping political outcomes.

      Organizations such as AIPAC have spent significant sums of money in U.S. elections, including targeting candidates who are critical of Israeli government policy. In recent election cycles, candidates such as Cori Bush and Jamaal Bowman faced well-funded opposition campaigns after taking such positions. The money AIPAC spent against these politicians contributed to them losing their seats. There is a growing pattern of well-funded political campaigns targeting candidates who are critical of Israeli government policy. In some cases, opposition research and past statements are amplified through media circulation. While this is common in politics broadly, the scale and consistency of spending from pro-Israel lobbying networks raises legitimate questions about their influence in shaping electoral outcomes. Graham Platner is a recent example.

      This raises a legitimate question: to what extent are financial networks and political advocacy groups shaping which candidates are viable?

      In the case of Nate Blouin, recent attention has focused heavily on resurfaced online comments from over a decade ago. Two things can be true at once: some past statements may have been inappropriate and worth acknowledging, yet the selective resurfacing and amplification of those statements may be related to his criticisms of Israel. Voters should ask themselves whether it is reasonable to treat online comments from 15+ years ago as disqualifying, particularly when there is limited evidence that such views reflect a candidate’s current positions.

      Similarly, critiques of Blouin’s legislative record in the Utah Senate should be understood in context. Utah operates under a one-party supermajority, where minority-party legislators often face structural barriers to passing legislation. This is more the case if they are vocally defiant toward the supermajority. This is not directly comparable to the dynamics of the U.S. House of Representatives where a supermajority doesn’t exist.

      More broadly, history shows that when candidates challenge powerful interests, coordinated efforts often emerge to discredit them. During the 2016 Democratic primary, for example, Bernie Sanders faced institutional resistance, including documented efforts within the Democratic National Committee to undermine his campaign. These patterns are not unique to any one issue or political faction. They reflect a recurring dynamic in democratic systems: power resists disruption.

      Finally, voters should consider what issues matter most. In 2024, Amnesty International concluded that Israel’s actions toward Palestinians constituted genocide, while the International Court of Justice found that claims of genocide were plausible. Despite this, many U.S. politicians including many Democrats continue to oppose conditioning aid to Israel. For voters, the question is not whether a candidate made offensive comments in 2009. The question is how much weight to give those comments relative to current policy positions on healthcare, foreign policy, and human rights.

      These concerns also intersect with broader debates about sovereignty and the responsiveness of institutions to the will of the American public. Public opinion data points to a consistent pattern: many Americans are skeptical of new military engagements in the Middle East, including conflict with Iran, and large majorities support greater transparency from government institutions, such as the full release of information related to the Epstein case. There are reasonable questions related to the role of Israel in these outcomes. When public preferences on issues like war and government transparency diverge from political outcomes, it raises broader questions about how responsive the system is to voters and what role organized interests play in shaping those outcomes.

      A functioning democracy requires evaluating both individual accountability and systemic influence. Ignoring either leads to an incomplete understanding of political reality.
    TEXT

    topic.update!(
      bio_heading: "Context for CD1 in Utah",
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
