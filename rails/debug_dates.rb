
content = File.read("app/history_education_content.txt")
entries = content.split("=" * 80)

entries.each_with_index do |entry, index|
  next if entry.strip.empty?
  
  lines = entry.strip.lines.map(&:strip)
  title = lines.find { |l| l.start_with?("TITLE:") }&.sub("TITLE:", "")&.strip
  content_body = lines.join("\n")
  
  # Search for any (X/Y) or (original post ...) patterns
  title_date = title.match(/\((\d{1,2})\/(\d{1,2})\)/)
  content_date = content_body.match(/\(original post (\d{2})\/(\d{2})\/(\d{4})\)/)
  
  if title_date
    # puts "Entry #{index+1}: Title Date found: #{title_date[0]}"
  elsif content_date
    # puts "Entry #{index+1}: Content Date found: #{content_date[0]}"
  else
    # Look for anything that looks like a date
    potential = content_body.scan(/\b(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, 202[4-6]\b/)
    if potential.any?
       puts "Entry #{index+1} (#{title}): Potential Date: #{potential.flatten.join(', ')}"
    end
    
    # Look for (X/Y) in content too
    potential_title_like = content_body.scan(/\(\d{1,2}\/\d{1,2}\)/)
    if potential_title_like.any?
       puts "Entry #{index+1} (#{title}): Potential Title-like Date in Content: #{potential_title_like.join(', ')}"
    end
  end
end
