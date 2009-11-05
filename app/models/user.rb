class User < ActiveRecord::Base
  has_many :ballots, :dependent => :destroy do
    def cast_for_election(election)
      self.find(:first,:conditions => ["ballots.election_id = ? AND ballots.cast_at IS NOT NULL",
                                       election.id])
    end
    def cast
      self.reject { |b| b.cast_at.nil? }
    end
  end
  has_many :candidates, :finder_sql => 
    'SELECT DISTINCT candidates.* FROM candidates INNER JOIN votes v INNER JOIN ballots b WHERE ' +
    'candidates.id=v.candidate_id AND v.ballot_id=b.id AND b.user_id=#{id}'
  has_and_belongs_to_many :rolls, :include => :election, :order => 'rolls.name' do
    def for_election(election)
      self.select { |r| r.election == election }
    end
  end
  has_many :elections, :finder_sql =>
    'SELECT DISTINCT elections.* FROM elections INNER JOIN rolls r INNER JOIN rolls_users l ' +
    'WHERE elections.id=r.election_id AND r.id=l.roll_id AND l.user_id=#{id} ' +
    'ORDER BY elections.name' do
    def past
      self.select { |e| e.voting_ends_at < Time.now }
    end
    def current
      self.select { |e| e.voting_starts_at < Time.now && e.voting_ends_at > Time.now }
    end
    def current_open
      self.current.reject { |e| proxy_owner.ballots.cast_for_election(e) }
    end
    def current_closed
      self.current.select { |e| proxy_owner.ballots.cast_for_election(e) }
    end
    def upcoming
      self.select { |e| e.voting_starts_at > Time.now }
    end
  end
  
  validates_uniqueness_of :net_id, :allow_nil => true
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
