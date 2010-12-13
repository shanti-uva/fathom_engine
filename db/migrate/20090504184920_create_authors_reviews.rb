class CreateAuthorsReviews < ActiveRecord::Migration
    def self.up
      create_table :authors_reviews, :id => false do |t|
        t.references :author, :null => false  # author is an User
        t.references  :review, :null => false  
      end
      add_index :authors_reviews, [:author_id, :review_id], :unique => true
    end

    def self.down
      drop_table :authors_reviews
    end
  end
