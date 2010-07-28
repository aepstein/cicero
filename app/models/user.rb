class User < ActiveRecord::Base
  default_scope :order => 'users.last_name ASC, users.first_name ASC, users.net_id ASC'
  scope_procedure :name_like, lambda { |name| last_name_or_first_name_or_net_id_like name }

  has_many :ballots, :dependent => :destroy
  has_and_belongs_to_many :rolls, :order => 'rolls.name'
  has_many :elections, :through => :ballots do
    def allowed
      Election.current.allowed_for_user_id(proxy_owner.id) - self
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

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def to_s; name; end
end

