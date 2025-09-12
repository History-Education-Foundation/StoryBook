class Page < ApplicationRecord
  belongs_to :chapter

  has_one_attached :image
  has_one_attached :audio_file
  def generate_picture(replace_existing: false)
    Rails.logger.info("[generate_picture] Page \\#{id} (content=#{content.inspect}) - replace_existing: \\#{replace_existing}")
    return :skipped if image.attached? && !replace_existing
    prompt = "This is the page content from a picture book, please generate an appropriate image that matches the content on the page. Here is the page content: <PAGE> #{content} </PAGE>"
    begin
      image.purge if image.attached? && replace_existing
      OpenAi.new.generate_image(prompt, attach_to: self, attachment_name: :image)
      Rails.logger.info("[generate_picture] SUCCESS for Page \\#{id}")
      :generated
    rescue => e
      Rails.logger.error("AI image generation failed for Page \\#{id}: \\#{e.message}")
      :failed
    end
  end
end

