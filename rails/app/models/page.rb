class Page < ApplicationRecord
  # Returns true if this page is the first in its chapter (by order of ID)
  def this_is_first_page_in_chapter?
    chapter.pages.order(:id).first&.id == self.id
  end

  # Returns true if this page is the first in the first chapter of the book
  def this_is_first_page_and_first_chapter?
    first_chapter = chapter.book.chapters.order(:id).first
    self.chapter_id == first_chapter.id && this_is_first_page_in_chapter?
  end

  belongs_to :chapter

  has_one_attached :image
  has_one_attached :audio_file
  def generate_picture(replace_existing: false, book_title: nil, book_level: nil, learning_objective: nil, previous_pages: nil)
    Rails.logger.info("[generate_picture] Page #{id} (content=#{content.inspect}) - replace_existing: #{replace_existing}")
    chapter_title = chapter.title.to_s.strip
    return :skipped if image.attached? && !replace_existing
    chapter = self.chapter
    book = chapter.book
    book_title = book.title.to_s.strip
    book_level = book.reading_level.to_s.strip
    learning_objective = book.learning_outcome.to_s.strip
    previous_pages = chapter.pages.order(:id).map { |p| p.content.to_s }.join("\n")
    if book_title && book_level && learning_objective && previous_pages
      prompt = "This is the page content from a picture book, please generate a very detailed and appropriate prompt to generate an image that matches the content on the page and learning outcomes for the book. " \
              "This book/chapter theme is: <CHAPTER_TITLE> #{chapter_title} </CHAPTER_TITLE>. " \
              "Here is the Book's title: <BOOK_TITLE> #{book_title} </BOOK_TITLE>, " \
              "Here is the book's target reading level: <TARGET_LEVEL> #{book_level} </TARGET_LEVEL>, " \
              "here is the book's subtitle/lesson objective: <LEARNING_OBJECTIVE> #{learning_objective} </LEARNING_OBJECTIVE>, " \
              "and here is all of the previous page's contents up to this page: <PREVIOUS_PAGE_CONTENT> #{previous_pages} </PREVIOUS_PAGE_CONTENT> " \
              "Here is the current page content that we need to generate an image for: <PAGE> #{content} </PAGE>. " \
              "Please ensure the image is historically and culturally accurate for any people created/portrayed, including ethnicity, gender, and age. Do NOT include any additional commentary or text, JUST respond with the prompt that we will pass directly into the image generator."
    else
      prompt = "This is the page content from a picture book, please generate an appropriate image that matches the content on the page. Here is the page content: <PAGE> #{content} </PAGE>"
    end
    begin
      prompt_from_openai = OpenAi.new.generate_text(prompt)
      image.purge if image.attached? && replace_existing
      byebug
      OpenAi.new.generate_image(prompt_from_openai, attach_to: self, attachment_name: :image)
      # Runware.new.generate_image(prompt, attach_to: self, attachment_name: :image)
      Rails.logger.info("[generate_picture] SUCCESS for Page #{id}")
      :generated
    rescue => e
      Rails.logger.error("AI image generation failed for Page #{id}: #{e.message}")
      :failed
    end
  end
end