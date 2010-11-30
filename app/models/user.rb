class User < ActiveRecord::Base
  has_many :ballots, :dependent => :destroy
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

  acts_as_authentic do |c|
    c.login_field :net_id
  end

  validates_presence_of :net_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_uniqueness_of :net_id

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

