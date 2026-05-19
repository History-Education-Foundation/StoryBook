namespace :import do
  desc "Import legacy content from app/history_education_content.txt"
  task legacy_content: :environment do
    stats = ContentImporter.call
    puts "Import complete!"
    puts "Created: #{stats[:created]}"
    puts "Matched: #{stats[:matched]}"
    puts "Failed:  #{stats[:failed]}"
    
    if stats[:failed] > 0
      puts "\nErrors:"
      stats[:details].each do |detail|
        puts "- #{detail}" if detail.start_with?("Error") || detail.include?("Failed")
      end
    end
  end
end
