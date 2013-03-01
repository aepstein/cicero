class Ballot < ActiveRecord::Base
  SEARCHABLE = [ :user_name_contains ]
  attr_accessible :confirmation, :sections_attributes
  attr_readonly :election_id, :user_id

  belongs_to :election, inverse_of: :ballots
  belongs_to :user, inverse_of: :ballots
  has_many :sections, inverse_of: :ballot, dependent: :destroy do
    def populate
      proxy_association.owner.races.allowed.includes { candidates }.each do |race|
        section = ( with_race_id(race.id) || build )
        section.race ||= race
        section.votes.populate
      end
    end
    def with_race_id( race_id )
      to_a.select { |section| section.race_id == race_id }.first
    end
  end
  has_many :races, through: :election do
    def allowed
      allowed_for_user( proxy_association.owner.user )
    end
  end

  scope :user_name_contains, lambda { |name|
    joins(:user).merge( User.unscoped.name_contains( name ) )
  }

  accepts_nested_attributes_for :sections

  search_methods :user_name_like

  validates :election, presence: true
  validates :user, presence: true
  validates :user_id, uniqueness: { scope: :election_id }

  after_create do |ballot|
    BallotMailer.verification( ballot ).deliver
  end

  def simple_errors
    errors.inject({}) do |errors, ( attribute, error )|
      errors[attribute] = error if attribute =~ /\./
      errors
    end
  end

  def confirmation
    @confirmation
  end

  def confirmation=(value)
    return @confirmation = false if value == 'false'
    return @confirmation = true if value == 'true'
    return @confirmation = value if value == true || value == false
    @confirmation = nil
  end

  def initialize_sections
    sections.each { |section| section.ballot = self if section.ballot.nil? }
  end

  def to_s
    if user && election
      "Ballot of #{user} for #{election}"
    else
      super
    end
  end

end

