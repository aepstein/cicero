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

    def import_from_string( string )
      import_from_csv( FasterCSV.parse(string) )
    end

    def import_from_file( file )
      import_from_csv( FasterCSV.parse(file.read) )
    end

    private

    def import_from_csv(values)
      original_roll_size = count
      original_user_size = User.count

      # Filter values for correctly formatted rolls only
      values = values.select { |row| row.size == 4 }
      # Get list of net ids to use
      import_net_ids = values.map { |row| row[0] }

      # Set up user records for any users not already in database
      import_net_ids_sql = import_net_ids.map { |net_id| connection.quote net_id }.join ", "
      current_user_net_ids = connection.select_values "SELECT net_id FROM users WHERE net_id IN (#{import_net_ids_sql})"
      import_net_ids_sql = nil
      values = values.reject { |row| current_user_net_ids.include?( row[0] ) }
      values.map! { |row| User.new( :net_id => row[0], :email => row[1], :first_name => row[2], :last_name => row[3] ) }
      values.each { |user| user.reset_password }
      User.import( values, :validate => false )
      values = nil

      # Add users to roll not already in the roll
      self<< User.find( :all, :conditions => [
        "users.net_id IN (?) AND users.id NOT IN (SELECT user_id FROM rolls_users AS ru WHERE ru.roll_id = ?)",
        import_net_ids,
        proxy_owner.id ] )
      [(self.size - original_roll_size), (User.count - original_user_size)]
    end
  end
  has_many :races, :order => 'races.name ASC', :dependent => :destroy

  validates_presence_of :election
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :election_id

  def may_user?(user, action)
    election.may_user?(user, action)
  end

  def to_s
    name
  end
end

