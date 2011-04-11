class Vote < ActiveRecord::Base
  attr_accessible :rank, :candidate_id, :candidate

  belongs_to :candidate
  belongs_to :section, :inverse_of => :votes

  validates_presence_of :rank
  validates_presence_of :candidate
  validates_presence_of :section
  validate :candidate_must_be_in_section_race,
    :ranked_vote_must_be_unique_and_sequential,
    :candidate_must_be_unique_in_section

  def to_s; "vote for #{candidate}"; end

  def <=>(aVote)
    return rand<=>rand if rank.nil? && aVote.rank.nil?
    return 1 if rank.nil? && aVote.rank
    return -1 if rank && aVote.rank.nil?
    return rank<=>aVote.rank if rank != aVote.rank
    candidate.name<=>aVote.candidate.name
  end

  protected

  def candidate_must_be_in_section_race
    return unless candidate && section && section.race
    unless section.race.candidates.exists?( candidate.id )
      errors.add :candidate_id, 'is not in the race for this section'
    end
  end

  def ranked_vote_must_be_unique_and_sequential
    return unless rank && section && section.race.is_ranked?
    ranks = section.votes.reject { |vote| vote === self }.map(&:rank)
    if ranks.include? rank
      errors.add :rank, 'is not unique for the race'
    end
    unless rank == 1 || ranks.include?(rank - 1)
      errors.add :rank, "is ranked #{rank} but there is no vote ranked #{rank-1}"
    end
  end

  def candidate_must_be_unique_in_section
    return unless candidate && section
    candidates = section.votes.reject { |vote| vote === self }.map(&:candidate)
    if candidates.include? candidate
      errors.add :candidate_id, 'is not unique for the race'
    end
  end

end

