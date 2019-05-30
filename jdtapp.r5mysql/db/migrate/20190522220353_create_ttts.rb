class CreateTtts < ActiveRecord::Migration[5.2]
  def change
    create_table :ttts do |t|
      t.string :name

      t.timestamps
    end
  end
end
