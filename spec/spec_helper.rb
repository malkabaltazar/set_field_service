require "active_record"
require "sqlite3"

RSpec.configure do |config|
  ActiveRecord::Base.establish_connection(
    adapter:  "sqlite3",
    database: "memory"
  )

  def create_prospects_table
    ActiveRecord::Base.connection.create_table("prospects") do |t|
      t.integer :prospect_id
      t.string :email
      t.integer :verified
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :title
      t.string :role
      t.integer :score
      t.timestamps
    end
    ActiveRecord::Base.connection.add_index :prospects, :email, unique: true
  end

  def drop_table(table_name)
    ActiveRecord::Base.connection.drop_table(table_name)
  end

  class EmailValidator
    def self.valid?(email)
      true unless email == "foo"
    end
  end

end