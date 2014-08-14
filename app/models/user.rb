class User < ActiveRecord::Base
  SEARCHABLE = [ :name_contains ]

  has_many :ballots, dependent: :destroy, inverse_of: :user
  has_and_belongs_to_many :rolls, -> { order { rolls.name } }
  has_many :elections, through: :ballots do
    def allowed
      Election.current.allowed_for_user(proxy_association.owner).
        where { |e| e.id.not_in( proxy_association.owner.ballots.scope.
          select { election_id } ) }
    end
  end

  default_scope -> { ordered }
  scope :ordered, -> { order { [ users.last_name, users.first_name, users.net_id ] } } 
  scope :name_contains, ->(name) {
    sql = %w( first_name last_name net_id ).map do |field|
      "users.#{field} LIKE :name"
    end
    where( sql.join(' OR '), :name => "%#{name}%" )
  }

  ransacker :name

  is_authenticable

  validates :net_id, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def name(format=nil)
    case format
    when :net_id
      "#{first_name} #{last_name} (#{net_id})".squeeze(' ')
    when :last_first
      "#{last_name}, #{first_name}".squeeze(' ')
    else
      "#{first_name} #{last_name}".squeeze(' ')
    end
  end

  def net_id_name
    "#{name} (#{net_id})"
  end

  def role_symbols
    return [:admin,:user] if admin?
    [:user]
  end

  def to_email; "#{name} <#{email}>"; end

  def to_s; name; end
end

