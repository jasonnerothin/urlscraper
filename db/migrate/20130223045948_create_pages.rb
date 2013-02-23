class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :id
      t.string :url
      t.text :json
      t.timestamps
    end
  end
end
