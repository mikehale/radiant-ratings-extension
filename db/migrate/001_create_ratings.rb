class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.column :rating,     :decimal, :null => false, :precision => 2, :scale => 1
      t.column :page_id,    :integer, :null => false
      t.column :user_token, :string,  :null => false
    end

    add_index :ratings, [:user_token, :page_id], :unique => true
  end

  def self.down
    drop_table :ratings
  end
end
