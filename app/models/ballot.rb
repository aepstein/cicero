class Ballot < ActiveRecord::Base
  belongs_to :election, :inverse_of => :ballots
  belongs_to :user, :inverse_of => :ballots
  has_many :sections, :inverse_of => :ballot, :dependent => :destroy do
    def populate
      proxy_owner.races.allowed.each do |race|
        section = ( with_race_id(race.id) || build( :race => race ) )
        section.votes.populate
      end
    end
    def with_race_id( race_id )
      to_a.select { |section| section.race_id == race_id }.first
    end
  end
  has_many :races, :through => :election do
    def allowed
      allowed_for_user_id( proxy_owner.user_id )
    end
  end

  scope :user_name_like, lambda { |name|
    joins(:user) & User.name_like( name )
  }

  accepts_nested_attributes_for :sections

  search_methods :user_name_like

  validates_presence_of :election
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [ :election_id ]

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
    user.to_s
  end

end

