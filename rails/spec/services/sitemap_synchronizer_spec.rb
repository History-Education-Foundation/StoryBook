require 'rails_helper'

RSpec.describe SitemapSynchronizer do
  describe ".format_content" do
    it "converts short lines without punctuation to H2 headers" do
      raw_content = <<~TEXT
        Introduction
        This is a normal paragraph that should be wrapped in p tags.
        
        Leadership Through Self-Education
        Another paragraph here.
      TEXT
      
      formatted = SitemapSynchronizer.format_content(raw_content)
      
      expect(formatted).to include("<h2>Introduction</h2>")
      expect(formatted).to include("<p>This is a normal paragraph that should be wrapped in p tags.</p>")
      expect(formatted).to include("<h2>Leadership Through Self-Education</h2>")
      expect(formatted).to include("<p>Another paragraph here.</p>")
    end

    it "does not convert lines with punctuation to headers" do
      raw_content = "This is a sentence."
      formatted = SitemapSynchronizer.format_content(raw_content)
      expect(formatted).to include("<p>This is a sentence.</p>")
      expect(formatted).not_to include("<h2>")
    end

    it "strips original post date lines" do
      raw_content = <<~TEXT
        (original post 07/17/2026)
        This is content.
      TEXT
      formatted = SitemapSynchronizer.format_content(raw_content)
      expect(formatted).not_to include("original post")
      expect(formatted).to include("<p>This is content.</p>")
    end
  end
end
