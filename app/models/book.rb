class Book < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  has_many :saved_books, dependent: :destroy
  has_many :saved_by_users, through: :saved_books, source: :user

  STATUSES = ["Draft", "Published", "Archived"].freeze

  after_initialize do
    self.status ||= "Draft"
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
