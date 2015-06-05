ActiveRecord::Schema.define do
  create_table :posts, :force => true do |table|
    table.string  :subject
    table.text    :content
    table.integer :user_id
    table.timestamps null: false
  end

  create_table :users, :force => true do |table|
    table.string :email
    table.timestamps null: false
  end
end
