class User < ActiveRecord::Base
  attr_accessible :net_id, :first_name, :last_name, :admin, :email, :password,
    :password_confirmation, :roll_ids

  ADMIN_UPDATABLE = [ :net_id, :admin, :roll_ids ]

  has_many :ballots, :dependent => :destroy, :inverse_of => :user
  has_and_belongs_to_many :rolls, :order => 'rolls.name'
  has_many :elections, :through => :ballots do
    def allowed
      Election.current.allowed_for_user_id(proxy_owner.id) - self
    end
  end

  default_scope order( 'users.last_name ASC, users.first_name ASC, users.net_id ASC' )
  scope :name_like, lambda { |name|
    where %w( last_name first_name net_id ).map { |t| "users.#{t} LIKE :name" }.join(' OR '),
      :name => "%#{name}%"
  }

  search_methods :name_like

  is_authenticable

  validates :net_id, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def name
    ("#{first_name} #{last_name}").squeeze(' ')
  end

  def net_id_name
    "#{name} (#{net_id})"
  end

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def to_s; name; end
end

