class AddStreamTokenToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :stream_token, :string

    say_with_time "Backfilling stream_token for existing users" do
      user_class = Class.new(ActiveRecord::Base) do
        self.table_name = "users"
      end

      user_class.reset_column_information
      user_class.find_each(batch_size: 100) do |u|
        u.update_columns(stream_token: SecureRandom.uuid)
      end
    end

    change_column_null :users, :stream_token, false
    add_index :users, :stream_token, unique: true
  end

  def down
    remove_index :users, :stream_token if index_exists?(:users, :stream_token)
    remove_column :users, :stream_token if column_exists?(:users, :stream_token)
  end
end
