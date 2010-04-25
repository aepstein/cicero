class Section < ActiveRecord::Base
  attr_accessor :warning

  belongs_to :ballot
  belongs_to :race
  has_many :votes, :order => 'votes.rank' do
    def populate
      proxy_owner.race.candidates.each do |candidate|
        build(:candidate => candidate) unless candidate_ids.include? candidate.id
      end
    end
    def candidate_ids
      map { |vote| vote.candidate_id }
    end
    def ranks
      map { |vote| vote.rank }
    end
  end

  validates_presence_of :ballot
  validates_presence_of :race
  validates_uniqueness_of :race_id, :scope => [ :ballot_id ]
  validate :votes_must_be_unique, :user_must_be_in_race_roll, :votes_must_not_exceed_maximum

  before_validation :initialize_votes

  accepts_nested_attributes_for :votes, :reject_if => proc { |a| a['rank'].to_i == 0 }

  def to_blt
    votes.collect { |vote| race.candidate_ids.index(vote.candidate_id) + 1 }.join(' ')
  end

  private

  def initialize_votes
    votes.each { |vote| vote.section = self if vote.section.nil? }
  end

  def user_must_be_in_race_roll
    return unless race && ballot
    unless race.roll.users.exists?(ballot.user_id)
      errors.add :race_id, 'does not have the user in its roll'
    end
  end

  def votes_must_be_unique
    ranks = []
    candidate_ids = []
    votes.each do |vote|
      if race.is_ranked?
        if ranks.include?(vote.rank)
          vote.errors.add :rank, 'is not unique for the race'
        end
        unless vote.rank == 1 || votes.ranks.include?(vote.rank - 1)
          vote.errors.add :rank, "is ranked #{vote.rank} but there is no vote ranked #{vote.rank-1}"
        end
      end
      ranks << vote.rank
      if vote.candidate_id && candidate_ids.include?(vote.candidate_id)
          vote.errors.add :candidate_id, 'is not unique for the race'
      end
      candidate_ids << vote.candidate_id unless vote.candidate_id.nil?
      # TODO verify write-in is unique
    end
  end

  def votes_must_not_exceed_maximum
    return unless race
    over = votes.size - race.max_votes
    if over > 0
      errors.add_to_base "#{over} votes are selected beyond the #{race.max_votes} that are allowed for the race #{race.name}"
    elsif over < 0
      self.warning = "#{over.abs} fewer votes are selected than the #{race.max_votes} that are allowed for the race #{race.name}"
    end
  end

end

