class SitemapSynchronizer
  DELIMITER = "=" * 80
  
  def self.call(file_path = "app/history_education_content.txt")
    new(file_path).sync
  end

  def initialize(file_path)
    @file_path = file_path
    @admin_user = User.find_by(email: "kody@llamapress.ai") || User.first
    @base_date = Date.new(2026, 1, 12)
    @stats = { destroyed: 0, created: 0, failed: 0, errors: [] }
  end

  def sync
    cleanup
    import
    @stats
  end

  def self.format_content(raw_content)
    new(nil).format_content(raw_content)
  end

  def format_content(raw_content)
    return "" if raw_content.blank?
    
    lines = raw_content.split("\n")
    formatted_lines = []
    
    lines.each do |line|
      clean_line = line.strip
      next if clean_line.empty?
      
      # Skip date lines if they are the only thing on the line
      next if clean_line =~ /\A\(original post \d{2}\/\d{2}\/\d{4}\)\z/
      next if clean_line =~ /\A(January|February|March|April|May|June|July|August|September|October|November|December) \d{1,2}, 202\d\z/

      if is_header?(clean_line)
        formatted_lines << "<h2>#{clean_line}</h2>"
      else
        formatted_lines << "<p>#{clean_line}</p>"
      end
    end
    
    formatted_lines.join("\n")
  end

  def is_header?(line)
    return false if line.length > 60
    return false if line.end_with?(".", "?", "!")
    return false if line.match?(/\A\d+\./) # Starts with "1." etc (list)
    
    true
  end

  private

  def cleanup
    # 1. Delete all Post records where legacy_url is present
    posts_to_delete = Post.where.not(legacy_url: nil)
    @stats[:destroyed] += posts_to_delete.count
    posts_to_delete.destroy_all

    # 2. Delete all HistoricalFigure records
    @stats[:destroyed] += HistoricalFigure.count
    HistoricalFigure.destroy_all

    # 3. Delete all CivicTopic records
    @stats[:destroyed] += CivicTopic.count
    CivicTopic.destroy_all
  end

  def parse_sitemap_urls
    return [] unless File.exist?(@file_path)
    File.read(@file_path).scan(/URL: (.*)/).flatten.map(&:strip)
  end

  def import
    return unless File.exist?(@file_path)
    content = File.read(@file_path)
    entries = content.split(DELIMITER)
    
    entries.each_with_index do |entry, index|
      next if entry.strip.empty?

      begin
        data = parse_entry(entry)
        create_post(data, index)
      rescue => e
        @stats[:failed] += 1
        @stats[:errors] << "Error importing entry at index #{index}: #{e.message}"
      end
    end
  end

  def parse_entry(entry)
    lines = entry.strip.lines.map(&:strip)
    url = lines.find { |l| l.start_with?("URL:") }&.sub("URL:", "")&.strip
    title = lines.find { |l| l.start_with?("TITLE:") }&.sub("TITLE:", "")&.strip
    
    content_start_index = lines.index { |l| l.start_with?("CONTENT:") }
    content_body_raw = ""
    if content_start_index
      content_body_raw = lines[(content_start_index + 1)..-1].join("\n")
    end

    {
      url: url,
      title: title,
      content_raw: content_body_raw
    }
  end

  def create_post(data, index)
    return if data[:content_raw].blank?

    post_date = extract_date(data[:title], data[:content_raw]) || @base_date
    
    # Preserve order by subtracting seconds based on index.
    # Index 0 will be the newest (latest timestamp).
    published_at = post_date.to_time.end_of_day - index.seconds

    formatted_content = format_content(data[:content_raw])
    cleaned_title = clean_title(data[:title], data[:url])

    post = Post.new(
      title: cleaned_title,
      legacy_url: data[:url],
      user: @admin_user,
      created_at: published_at,
      updated_at: published_at,
      status: :published
    )
    
    post.body = formatted_content
    
    if post.save
      @stats[:created] += 1
    else
      @stats[:failed] += 1
      @stats[:errors] << "Failed to save Post '#{cleaned_title}': #{post.errors.full_messages.join(", ")}"
    end
  end

  def clean_title(title, url)
    return "Untitled" if title.blank?
    
    # If title is a URL, extract and clean the slug
    if title.start_with?("http")
      slug = url.split("/").last
      return slug.gsub("-", " ").capitalize if slug.present?
    end

    # Strip (M/D) from title
    title.gsub(/\s*\(\d{1,2}\/\d{1,2}\)/, "").strip
  end

  def extract_date(title, content)
    # 1. Check content for (original post MM/DD/YYYY) format
    if content =~ /\(original post (\d{2})\/(\d{2})\/(\d{4})\)/
      return Date.new($3.to_i, $1.to_i, $2.to_i)
    end

    # 2. Check title for (MM/DD) format
    if title =~ /\((\d{1,2})\/(\d{1,2})\)/
      return Date.new(2026, $1.to_i, $2.to_i)
    end

    # 3. Check content for start (MM/DD) format
    if content =~ /\A\((\d{1,2})\/(\d{1,2})\)/
      return Date.new(2026, $1.to_i, $2.to_i)
    end

    # 4. Check content for "Month Day, Year" format (e.g. February 21, 2026)
    if content =~ /\b(January|February|March|April|May|June|July|August|September|October|November|December) (\d{1,2}), (202\d)\b/
      month_name = $1
      day = $2.to_i
      year = $3.to_i
      month = Date::MONTHNAMES.index(month_name)
      return Date.new(year, month, day) if month
    end

    nil
  end
end
