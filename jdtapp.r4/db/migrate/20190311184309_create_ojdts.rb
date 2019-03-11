class CreateOjdts < ActiveRecord::Migration
  def change
    create_table :ojdts do |t|

      t.timestamps null: false
    end
  end
end
