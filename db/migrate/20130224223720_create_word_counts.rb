class CreateWordCounts < ActiveRecord::Migration

  def up
    create_table :word_counts do |t|
      t.string :word
      t.integer :count
      t.references :page
      t.timestamps
    end
  end

  def down
    drop_table :word_counts
  end

end
