class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :url
      t.text :json
      t.timestamps
    end
  end

  def down
    drop_table :pages
  end
end
