require 'rails_helper'

RSpec.describe ContentImporter do
  let(:sample_content) do
    <<~CONTENT
      URL: https://www.history-education.org/frederick-douglass/
      TITLE: Frederick Douglass
      CONTENT:
      Frederick Douglass was a leader.
      
      Main Ideas
      Education is power.
      
      Legacy
      He changed America.
      
      ================================================================================
      
      URL: https://www.history-education.org/civics-lesson-plan/
      TITLE: Civics Lesson Plan
      CONTENT:
      This is a lesson plan about civics.
      
      ================================================================================
      
      URL: https://www.history-education.org/constitutional-crisis/
      TITLE: The Crisis
      CONTENT:
      This was a major crisis.
      
      ================================================================================
      
      URL: https://www.history-education.org/blog-post/
      TITLE: A Random Post
      CONTENT:
      Just some thoughts.
    CONTENT
  end

  let(:temp_file) { Rails.root.join("tmp", "test_import.txt") }

  before do
    File.write(temp_file, sample_content)
    # Ensure a user exists for Posts
    User.find_or_create_by!(email: "admin@example.com") do |u|
      u.password = "password"
      u.name = "Admin"
    end
  end

  after do
    File.delete(temp_file) if File.exist?(temp_file)
  end

  describe ".call" do
    it "imports historical figures" do
      expect {
        ContentImporter.call(temp_file)
      }.to change(HistoricalFigure, :count).by(1)
      
      figure = HistoricalFigure.find_by(name: "Frederick Douglass")
      expect(figure.bio).to include("Frederick Douglass was a leader.")
      expect(figure.main_ideas).to include("Education is power.")
      expect(figure.legacy).to include("He changed America.")
      expect(figure.legacy_url).to eq("https://www.history-education.org/frederick-douglass/")
    end

    it "imports civic topics with lesson plan flag" do
      expect {
        ContentImporter.call(temp_file)
      }.to change(CivicTopic, :count).by(1)
      
      topic = CivicTopic.find_by(name: "Civics Lesson Plan")
      expect(topic.is_lesson_plan).to be true
    end

    it "imports controversies" do
      expect {
        ContentImporter.call(temp_file)
      }.to change(Controversy, :count).by(1)
      
      controversy = Controversy.find_by(name: "The Crisis")
      expect(controversy.legacy_url).to include("constitutional-crisis")
    end

    it "imports posts as fallback" do
      expect {
        ContentImporter.call(temp_file)
      }.to change(Post, :count).by(1)
      
      post = Post.find_by(title: "A Random Post")
      expect(post.body.to_plain_text).to include("Just some thoughts.")
    end

    it "deduplicates by legacy_url" do
      ContentImporter.call(temp_file)
      expect {
        ContentImporter.call(temp_file)
      }.not_to change(HistoricalFigure, :count)
    end
  end
end
