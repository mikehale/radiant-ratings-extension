class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.column :rating,     :decimal, :null => false, :precision => 1, :scale => 2
      t.column :page_id,    :integer, :null => false
      t.column :user_token, :string,  :null => false
    end
    
    add_index :ratings, :user_token
  end

  def self.down
    drop_table :ratings
  end
end
