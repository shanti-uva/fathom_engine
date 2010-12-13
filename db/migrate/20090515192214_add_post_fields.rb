class AddPostFields < ActiveRecord::Migration
  # Adds fields for new post feature.
  def self.up
    # Create the post_kinds table.
    create_table :post_kinds, :force => true do |t|
      t.column :post_kind_id, :string
      t.column :post_kind_value, :string
      t.timestamps
    end

    # Populate the initial post_kinds table.
    say_with_time "Initializing post kinds..." do
      { :announcement => "Announcement",
        :collaborators => "Seeking Collaborators",
        :employees => "Seeking Employees",
        :work => "Seeking Work",
        :research => "Seeking Research"}.each do |k, v|
        say "  Adding [" + k.to_s + "] [" + v.to_s + "]"
        PostKind.create(:post_kind_id => k, :post_kind_value => v)
      end
    end

    add_column :posts, :sponsor_entity_id, :integer, :limit => 11
    add_column :posts, :post_kind_id, :string
    add_column :posts, :post_category, :string
    add_column :posts, :expiration_date, :datetime
    add_column :posts, :response_email, :string

    Post.all.each do |p|
      # Give all existing posts an expiration date of 3 months from now, and assume that they're of the
      # announcement type.
      p.expiration_date = Time.now.months_since(3)
      p.post_kind = PostKind.find(:all, :conditions => {:post_kind_id => :announcement}).first
      p.body = "Blank post." if p.body.empty?
      p.subject = "Unnamed Post" if p.subject.empty?

      # Assign posts a blank e-mail address initially.
      p.response_email = ""

      # Don't do validation.
      p.save(false)
    end
  end

  def self.down
    remove_column :posts, :sponsor_entity_id
    remove_column :posts, :post_kind_id
    remove_column :posts, :post_category
    remove_column :posts, :expiration_date
    remove_column :posts, :response_email

    drop_table :post_kinds
  end
end