class Roll < ActiveRecord::Base
  attr_accessible :name
  attr_readonly :election_id

  belongs_to :election, :inverse_of => :rolls
  has_many :candidates, :through => :races
  has_and_belongs_to_many :users do
    def find_by_net_id_or_name(search)
      q = "%#{search}%"
      find( :all,
            :conditions => [
              'net_id LIKE ? OR first_name LIKE ? OR last_name LIKE ?', q, q, q
      ] )
    end

    def import_from_string( string )
      import_from_csv( CSV.parse(string) )
    end

    def import_from_file( file )
      import_from_csv( CSV.parse(file.read) )
    end

    private

    def import_from_csv(values)
      original_roll_size = count

      # Filter values for correctly formatted rolls only
      values = values.select { |row| row.size == 4 }
      return [0,0] if values.empty?
      import_net_ids_sql = values.map { |row| connection.quote row[0] }.join ", "

      # Set up user records for any users not already in database
      current_user_net_ids = connection.select_values "SELECT net_id FROM users WHERE net_id IN (#{import_net_ids_sql})"
      values = values.reject { |row| current_user_net_ids.include?( row[0] ) }
      unless values.empty?
        values.map! { |row| User.new( :net_id => row[0], :email => row[1], :first_name => row[2], :last_name => row[3] ) }
        values.each { |user| user.reset_password }
        user_import = User.import( values, :validate => false )
        values = nil
      end

      # Add users to roll not already in the roll
      connection.insert_sql "INSERT INTO rolls_users ( roll_id, user_id )
        SELECT #{connection.quote proxy_owner.id}, u.id FROM users AS u WHERE
        u.net_id IN (#{import_net_ids_sql}) AND u.id NOT IN
        (SELECT user_id FROM rolls_users AS ru WHERE ru.roll_id = #{connection.quote proxy_owner.id})"
      [(size - original_roll_size), (user_import.nil? ? 0 : user_import.num_inserts) ]
    end
  end
  has_many :races, :order => 'races.name ASC', :dependent => :destroy

  validates_presence_of :election
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :election_id

  def to_s; name; end
end

