class Section < ActiveRecord::Base
  belongs_to :ballot
  belongs_to :race
  has_many :votes do
    def ranks
      select { |vote| vote.rank }
    end
  end

  validates_presence_of :ballot
  validates_presence_of :race
  validate :votes_must_be_unique

  before_validation :initialize_votes

  accepts_nested_attributes_for :votes

  private

  def initialize_votes
    votes.each { |vote| vote.section = self if vote.section.nil? }
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
      end
      candidate_ids << vote.candidate_id unless vote.candidate_id.nil?
      # TODO verify write-in is unique
    end
  end
end

