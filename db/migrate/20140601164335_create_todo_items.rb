class CreateTodoItems < ActiveRecord::Migration
  def change
    create_table :todo_items do |t|
      t.references :todo_list
      t.string :content

      t.timestamps
    end
  end
end