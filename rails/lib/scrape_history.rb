require 'net/http'
require 'nokogiri'
require 'uri'

sitemaps = [
  "https://www.history-education.org/wp-sitemap-posts-post-1.xml",
  "https://www.history-education.org/wp-sitemap-posts-page-1.xml"
]

all_urls = []

sitemaps.each do |sitemap_url|
  puts "Fetching sitemap: #{sitemap_url}"
  uri = URI(sitemap_url)
  response = Net::HTTP.get(uri)
  xml = Nokogiri::XML(response)
  xml.xpath("//xmlns:loc").each do |loc|
    all_urls << loc.text
  end
end

puts "Found #{all_urls.size} URLs. Starting scrape..."

output_file = "public/history_education_content.txt"
File.open(output_file, "w") do |file|
  all_urls.each_with_index do |url, index|
    puts "[#{index + 1}/#{all_urls.size}] Scraping #{url}..."
    begin
      uri = URI(url)
      response = Net::HTTP.get(uri)
      doc = Nokogiri::HTML(response)

      # Remove script and style elements
      doc.xpath('//script').remove
      doc.xpath('//style').remove

      # Try to find common WP content containers
      content_node = doc.at_css('.entry-content') || doc.at_css('article') || doc.at_css('main') || doc.body

      if content_node
        title = doc.at_css('h1')&.text&.strip || url
        # Clean up text: remove extra whitespace and newlines
        text = content_node.text.split("\n").map(&:strip).reject(&:empty?).join("\n")

        file.puts "URL: #{url}"
        file.puts "TITLE: #{title}"
        file.puts "CONTENT:"
        file.puts text
        file.puts "\n" + ("=" * 80) + "\n\n"
      end
    rescue => e
      puts "Error scraping #{url}: #{e.message}"
    end
    # Small sleep to be polite
    sleep 0.1
  end
end

puts "Scrape complete. Saved to #{output_file}"
