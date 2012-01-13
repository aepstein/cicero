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

    # Takes parsed CSV and:
    # * creates users for any users not previously registered
    # * adds to roll any users not already enrolled
    def import_from_csv(values)
      # Filter values for correctly formatted rolls only
      values = values.select { |row| row.size == 4 }
      return [0,0] if values.empty?
      import_net_ids_sql = values.map { |row| connection.quote row[0] }.join ", "

      # Set up user records for any users not already in database
      current_user_net_ids = connection.select_values(
        "SELECT DISTINCT net_id FROM users WHERE net_id IN (#{import_net_ids_sql})" )
      values.reject! { |row| current_user_net_ids.include?( row[0] ) }
      if values.empty?
        user_import = 0
      else
        user_import = values.length
        values.map! do |row|
          u = User.new
          u.net_id, u.email, u.first_name, u.last_name = row[0], row[1], row[2], row[3]
          u
        end
        User.import values, validate: false
      end

      # Record initial roll size
      original_roll_size = count
      reset

      # Add users to roll not already in the roll
      connection.insert_sql "INSERT INTO rolls_users ( roll_id, user_id )
        SELECT #{connection.quote proxy_association.owner.id}, u.id FROM users AS u WHERE
        u.net_id IN (#{import_net_ids_sql}) AND u.id NOT IN
        (SELECT user_id FROM rolls_users AS ru
        WHERE ru.roll_id = #{connection.quote proxy_association.owner.id})"
      [(count - original_roll_size), user_import ]
    end
  end
  has_many :races, order: 'races.name ASC', dependent: :destroy

  validates :election, presence: true
  validates :name, presence: true, uniqueness: { scope: :election_id }

  def to_s; name; end
end

