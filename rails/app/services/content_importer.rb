class ContentImporter
  DELIMITER = "=" * 80

  def self.call(file_path = "app/history_education_content.txt")
    new(file_path).import
  end

  def initialize(file_path)
    @file_path = file_path
    @stats = { created: 0, matched: 0, failed: 0, details: [] }
  end

  def import
    content = File.read(@file_path)
    entries = content.split(DELIMITER)

    entries.each do |entry|
      next if entry.strip.empty?

      begin
        parsed_data = parse_entry(entry)
        process_entry(parsed_data)
      rescue => e
        @stats[:failed] += 1
        @stats[:details] << "Error parsing entry: #{e.message}"
      end
    end

    @stats
  end

  private

  def parse_entry(entry)
    lines = entry.strip.lines.map(&:strip)
    url = lines.find { |l| l.start_with?("URL:") }&.sub("URL:", "")&.strip
    title = lines.find { |l| l.start_with?("TITLE:") }&.sub("TITLE:", "")&.strip
    
    content_start_index = lines.index { |l| l.start_with?("CONTENT:") }
    content_body = ""
    if content_start_index
      content_body = lines[(content_start_index + 1)..-1].join("\n")
    end

    {
      url: url,
      title: title,
      content: content_body
    }
  end

  def process_entry(data)
    model_class = select_model(data)
    segments = segment_content(data[:content])
    
    record = find_or_initialize_record(model_class, data)
    
    if record.new_record?
      @stats[:created] += 1
    else
      @stats[:matched] += 1
    end

    assign_attributes(record, data, segments)
    
    if record.save
      @stats[:details] << "Imported #{model_class}: #{data[:title]}"
    else
      @stats[:failed] += 1
      @stats[:details] << "Failed to save #{model_class} '#{data[:title]}': #{record.errors.full_messages.join(", ")}"
    end
  end

  def select_model(data)
    url = data[:url].to_s.downcase
    title = data[:title].to_s.downcase

    if url.include?("lesson-plan")
      CivicTopic
    elsif url.include?("crisis") || url.include?("intervention") || url.include?("controversy")
      Controversy
    elsif url.include?("civics")
      CivicTopic
    elsif suggests_person?(data[:title], data[:url])
      HistoricalFigure
    else
      Post
    end
  end

  def suggests_person?(title, url)
    # Common historical figures or names
    return true if title.match?(/Frederick Douglass|Andrew Yang|Bernie Sanders|James Lindsay|Epstein/i)
    
    # If title starts with a name or contains "Leadership" or "Bio"
    # and isn't caught by other rules
    words = title.split
    # Check for name-like pattern: First Last (capitalized)
    has_name_pattern = title.match?(/^[A-Z][a-z]+ [A-Z][a-z]+/)
    
    has_name_pattern || title.include?("Biography")
  end

  def segment_content(content)
    segments = {
      main_ideas: [],
      legacy: [],
      criticism: [],
      default: []
    }

    current_section = :default
    
    content.split("\n").each do |line|
      clean_line = line.strip
      next if clean_line.empty?

      # Only match as header if the line is relatively short (e.g. < 50 chars)
      # and matches the keywords
      if clean_line.length < 50
        case clean_line
        when /^Main Ideas$|^Key Concepts$|^Student Comprehension/i, /Main Ideas:|Key Concepts:|Leadership|Principles/i
          current_section = :main_ideas
          next
        when /^Legacy$|^Impact$|^Why .* Matters$/i, /Legacy:|Impact:|Importance|Matters|Influence/i
          current_section = :legacy
          next
        when /^Criticism$|^Contradiction$|^Challenge/i, /Criticism:|Contradiction:|Challenge:|Opposition/i
          current_section = :criticism
          next
        end
      end

      segments[current_section] << line if segments.key?(current_section)
    end

    segments.transform_values { |v| v.join("\n").strip }
  end

  def find_or_initialize_record(model_class, data)
    record = model_class.find_by(legacy_url: data[:url]) if data[:url].present?
    return record if record

    name_field = model_class == Post ? :title : :name
    record = model_class.find_by(name_field => data[:title]) if data[:title].present?
    return record if record

    model_class.new(legacy_url: data[:url])
  end

  def assign_attributes(record, data, segments)
    if record.is_a?(Post)
      record.title = data[:title]
      record.body = build_full_content(segments)
      record.user ||= User.first
    else
      record.name = data[:title]
      record.bio = segments[:default]
      record.main_ideas = segments[:main_ideas]
      record.legacy = segments[:legacy]
      record.criticism = segments[:criticism]
      
      # Handle content preservation: if a section can't be categorized, append it to main bio
      # In my segment_content, everything starts in :default unless matched.
      # If we want to be more explicit about "unmatched" sections:
      # My current implementation keeps everything that doesn't match a header in the "bio" (default).
      
      if record.is_a?(CivicTopic) && data[:url].to_s.include?("lesson-plan")
        record.is_lesson_plan = true
      end
    end
  end

  def build_full_content(segments)
    full_body = [segments[:default], segments[:main_ideas], segments[:legacy], segments[:criticism]].reject(&:empty?).join("\n\n")
    full_body.presence || "No content provided."
  end
end
