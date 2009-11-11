class Ballot < ActiveRecord::Base
  attr_accessor :confirmation

  belongs_to :election
  belongs_to :user
  has_many :sections do
    def for_race( race )
      select { |section| section.race_id == race.id }.first
    end
    def populate
      proxy_owner.races.allowed.each do |race|
        section = for_race(race) || build( :race => race )
        section.votes.populate
      end
    end
  end
  has_many :races, :through => :election do
    def allowed
      allowed_for_user( proxy_owner.user )
    end
  end
  has_many :votes, :dependent => :delete_all, :include => [ :candidate ],
    :order => 'votes.rank' do
    def for_race( race )
      votes = self.select { |vote| vote.candidate.race == race }
      return votes if race.is_ranked?
      votes.sort_by { |vote| vote.candidate }
    end
    def for_candidate( candidate )
      self.select { |v| v.candidate == candidate }.first
    end
    def conflict_with_vote( vote )
      self.for_race( vote.candidate.race ).select { |v| (v != vote) && (v.rank == vote.rank) }
    end
    def first_before_vote( vote )
      self.select { |v| ( v.rank == (vote.rank - 1) ) }.first
    end
    def left_for_race( race )
      race.max_votes - for_race(race).size
    end
    def candidates
      self.collect { |v| v.candidate }
    end
  end

  accepts_nested_attributes_for :sections

  validates_presence_of :election
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [ :election_id ]
  validates_associated :votes
  validate :sections_must_be_unique

  before_validation :initialize_sections
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

  def initialize_sections
    sections.each { |section| section.ballot = self if section.ballot.nil? }
  end

  # Reviews choices and registers error for any candidate with invalid entry
  def validate_set(race)
    race_choices = votes.for_race(race)
    errors.add( :votes,
                "You have selected #{difference_for_race(race_choices,race)} for #{race}"
              ) if race_choices.size > race.max_votes
    warnings[race]=(
                     "You have selected #{difference_for_race(race_choices,race)} for #{race}"
                   ) if race_choices.size < race.max_votes
  end

  # Correctly describes number of additional votes allowed
  def difference_for_race(race_choices,race)
    if race_choices.size != race.max_votes
      difference = race.max_votes - race_choices.size
      qualifier = "fewer" if difference > 0
      qualifier = "more" if difference < 0
      qualifier += " than the maximum allowed"
      return ( (difference.abs == 1) ? '1 vote' : "#{difference.abs} votes" ) + " #{qualifier}"
    end
  end

  # Warnings about possibly invalid votes
  def warnings
    @warnings ||= Hash.new
  end

  # Casts the ballot
  # Will not recast a ballot that has already been cast or was confirmed before last update
  def cast(confirmed_at)
    return false if cast_at? || (confirmed_at < updated_at)
    self.cast_at=Time.now
    save
  end

  def to_s
    "ballot of #{user} for #{election}"
  end

  def may_user?(user,action)
    case action
      when :show, :update, :cast
        self.user == user && user.elections.current.include?(election) && cast_at.nil?
      when :verify
        (self.user == user || user.admin?) && cast_at
      when :delete
        user.admin? ||
          ( election.managers.include?(user) && Time.now < election.voting_ends_at ) ||
          (self.user == user && user.elections.current.include?(election) && cast_at.nil?)
      when :index
        user.admin? || election.managers.include?(user)
      when :new, :create
        self.user == user && user.elections.current.include?(election)
    end
  end

  def to_blt(race)
    votes.collect { |vote| race.candidate_ids.index(vote.candidate_id)
}.map { |ix| ix + 1 }.join(' ')
  end

end

