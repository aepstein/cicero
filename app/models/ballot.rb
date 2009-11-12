class Ballot < ActiveRecord::Base
  attr_accessor :confirmation

  belongs_to :election
  belongs_to :user
  has_many :sections do
    def with_race_id( race_id )
      self.select { |section| section.race_id == race_id }.first
    end
    def populate
      proxy_owner.races.allowed.each do |race|
        section = ( with_race_id(race.id) || build( :race => race ) )
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

  def to_s
    "ballot of #{user} for #{election}"
  end

  def may_user?(user,action)
    case action
      when :show
        (self.user == user || user.admin?)
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
    votes.collect { |vote| race.candidate_ids.index(vote.candidate_id) + 1 }.join(' ')
  end

end

