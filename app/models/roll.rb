class Roll < ActiveRecord::Base
  belongs_to :election
  has_many :candidates, :through => :races
  has_and_belongs_to_many :users do
    def find_by_net_id_or_name(search)
      q = "%#{search}%"
      find( :all,
            :conditions => ['net_id LIKE ? OR first_name LIKE ? OR last_name LIKE ?',
                            q,
                            q,
                            q ] )
    end
  end
  has_many :races, :order => 'races.name ASC', :dependent => :destroy
  
  def may_user?(user, action)
    election.may_user?(user, action)
  end
  
  def import_users_from_csv_string(string)
    return import_users(FasterCSV.parse(string))
  end
  
  def import_users_from_csv_file(file)
    return import_users(FasterCSV.parse(file.read))
  end
  
  def import_users(values)
    columns = [:net_id, :email, :first_name, :last_name]
    User.import( columns,
                 values,
                 { :on_duplicate_key_update => [:email, :first_name, :last_name],
                   :validate => false } )
    User.create_temporary_table
    TempUser.import( columns, values, :validate => false )
    num_inserts = connection.insert_sql(
      "INSERT INTO rolls_users (rolls_users.roll_id, rolls_users.user_id) " +
      "SELECT #{id}, users.id FROM users WHERE " +
      "users.net_id IN (SELECT temp_users.net_id FROM temp_users) AND " +
      "users.id NOT IN (SELECT rolls_users.user_id FROM rolls_users WHERE roll_id=#{id})"
    )
    TempUser.drop
    return num_inserts
  end
  
  def to_s
    name
  end
end
