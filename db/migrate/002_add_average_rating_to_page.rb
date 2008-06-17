class AddAverageRatingToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :average_rating, :decimal, :precision => 2, :scale => 1, :default => 0 
  end
  
  def self.down
    remove_column :pages, :average_rating
  end
end