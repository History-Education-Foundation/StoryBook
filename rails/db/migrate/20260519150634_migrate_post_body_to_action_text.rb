class MigratePostBodyToActionText < ActiveRecord::Migration[7.2]
  def up
    Post.all.each do |post|
      if post.body.blank? && post.read_attribute(:body).present?
        post.update(body: post.read_attribute(:body))
      end
    end
  end

  def down
  end
end
