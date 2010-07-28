class Ballot < ActiveRecord::Base
  belongs_to :election
  belongs_to :user
  has_many :sections, :dependent => :destroy do
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

  accepts_nested_attributes_for :sections

  before_validation :initialize_sections

  validates_presence_of :election
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [ :election_id ]
  validate :sections_must_be_unique

  def sections_must_be_unique
    race_ids = []
    sections.each do |section|
      if section.race_id && race_ids.include?(section.race_id)
        section.errors.add :race_id, 'is not unique for the ballot'
      end
      race_ids << section.race_id if section.race_id?
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
    user.to_s
  end

end

