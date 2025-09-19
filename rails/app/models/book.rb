class Book < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  has_many :saved_books, dependent: :destroy
  has_many :saved_by_users, through: :saved_books, source: :user
  has_many :pages, through: :chapters
  has_one_attached :audio_file

  STATUSES = ["Draft", "Published", "Archived"].freeze

  after_initialize do
    self.status ||= "Draft"
  end

  def generate_full_audio(voice: "alloy", format: "mp3")
    # Gather entire book, in reading order: Page Title > Chapter Title > Page Content
    lines = []
    chapters.order(:id).each do |chapter|
      chapter.pages.order(:id).each do |page|
        lines << "Page Title: #{page.title.to_s.strip}"
        lines << "Chapter Title: #{chapter.title.to_s.strip}"
        lines << page.content.to_s.strip
      end
    end
    text = lines.join(".\n")
    return if text.blank?

    ai = OpenAi.new
    ai.generate_audio(text, voice: voice, format: format, attach_to: self, attachment_name: :audio_file)
    self.save!
    self.audio_file
  rescue => e
    Rails.logger.error("Book audio generation failed: #{e.message}")
    nil
  end

  def generate_all_pictures(replace_existing: false)
    total = 0
    generated = 0
    failed = 0
    skipped = 0
    chapters.includes(:pages).find_each do |chapter|
      chapter.pages.find_each do |page|
        # Defensive safeguard - only attempt if image missing or we are forcing replacement
        next if page.image.attached? && !replace_existing
        total += 1
        result = page.generate_picture(replace_existing: replace_existing)
        case result
        when :generated
          generated += 1
        when :failed
          failed += 1
        when :skipped
          skipped += 1
        end
        sleep 1 # Prevent burst requests to OpenAI
      end
    end
    Rails.logger.info("[generate_all_pictures] Book \\#{id}: total=\\#{total}, generated=\\#{generated}, failed=\\#{failed}, skipped=\\#{skipped}")
    { total: total, generated: generated, failed: failed, skipped: skipped }
  end

  def retry_failed_pictures
    total = 0
    generated = 0
    failed = 0
    skipped = 0
    chapters.includes(:pages).find_each do |chapter|
      chapter.pages.left_outer_joins(:image_attachment)
        .where(active_storage_attachments: { id: nil })
        .find_each do |page|
          # Defensive check in case image was attached just prior
          next if page.image.attached?
          total += 1
          result = page.generate_picture
          case result
          when :generated
            generated += 1
          when :failed
            failed += 1
          when :skipped
            skipped += 1
          end
          sleep 1 # Prevent burst requests to OpenAI
        end
    end
    Rails.logger.info("[retry_failed_pictures] Book \\#{id}: total=\\#{total}, generated=\\#{generated}, failed=\\#{failed}, skipped=\\#{skipped}")
    { total: total, generated: generated, failed: failed, skipped: skipped }
  end
end
