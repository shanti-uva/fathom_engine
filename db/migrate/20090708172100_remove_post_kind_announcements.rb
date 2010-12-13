class RemovePostKindAnnouncements < ActiveRecord::Migration
  def self.up
    pk = PostKind.find_by_post_kind_id(:announcement)
    pk.destroy
  end

  def self.down
    # Add Post Kind Announcement
    say_with_time "Initializing post kinds..." do        
        say "  Adding [:announcement] [Announcement]"
        PostKind.create(:post_kind_id => :announcement, :post_kind_value => "Announcement")
    end
  end
end
