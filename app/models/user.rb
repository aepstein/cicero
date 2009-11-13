class User < ActiveRecord::Base
  has_many :ballots, :include => [:election], :dependent => :destroy do
    def elections
      map { |ballot| ballot.election }
    end
  end
  has_and_belongs_to_many :rolls, :order => 'rolls.name' do
    def for_election(election)
      to_a.select { |r| r.election == election }
    end
  end
  has_many :elections, :finder_sql =>
    'SELECT DISTINCT elections.* FROM elections INNER JOIN rolls r INNER JOIN rolls_users l ' +
    'WHERE elections.id=r.election_id AND r.id=l.roll_id AND l.user_id=#{id} ' +
    'ORDER BY elections.name' do
    def past
      to_a.select { |e| e.voting_ends_at < Time.now }
    end
    def current
      to_a.select { |e| e.voting_starts_at < Time.now && e.voting_ends_at > Time.now }
    end
    def current_open
      current - proxy_owner.ballots.elections
    end
    def current_closed
      current & proxy_owner.ballots.elections
    end
    def upcoming
      to_a.select { |e| e.voting_starts_at > Time.now }
    end
  end

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  validates_presence_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_uniqueness_of :net_id
  validates_presence_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => true

  def self.search(term,page)
    User.paginate :page => page,
                  :conditions => [ 'users.net_id LIKE ? ' +
                                      'OR users.first_name LIKE ? ' +
                                      'OR users.last_name LIKE ?',
                                   "%#{term}%","%#{term}%", "%#{term}%" ],
                  :order => "users.last_name, users.first_name, users.net_id"
  end

  def name
    ("#{first_name} #{last_name}").squeeze(' ')
  end

  def net_id_name
    "#{net_id} (#{name})"
  end

  def may?(action,object)
    object.may_user?(user,action)
  end

  def may_user?(user,action)
    user.admin?
  end

  def login!
    #update_attribute :last_login_at, Time.now
  end

  def to_s
    name
  end
end

