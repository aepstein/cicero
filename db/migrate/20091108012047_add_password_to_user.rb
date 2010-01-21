class AddPasswordToUser < ActiveRecord::Migration
  def self.up
#    add_column :users, :crypted_password, :string
#    add_column :users, :password_salt, :string
#    add_column :users, :persistence_token, :string
    say_with_time "Setting random passwords for all users" do
      User.reset_column_information
      last = User.last
      User.all.inject([]) do |memo, user|
        user.reset_password
        memo << [ user.id, user.crypted_password, user.password_salt, user.persistence_token
        ].map { |v| connection.quote v }
        if user == last || memo.length > 100
          fields = %w( crypted_password password_salt persistence_token )
          sql = (0..2).map do |i|
            "#{fields[i]} = " +
            "CASE users.id " + memo.map { |f| "WHEN #{f.first} THEN #{f[i+1]}" }.join(' ') + " END"
          end
          connection.execute "UPDATE users SET users.updated_at = #{connection.quote DateTime.now.utc}, " +
            "#{sql.join ', '} WHERE users.id IN (" + memo.map { |u| u.first }.join(', ') + ")"
          []
        else
          memo
        end
      end
    end
  end

  def self.down
    remove_column :users, :persistence_token
    remove_column :users, :password_salt
    remove_column :users, :crypted_password
  end
end

