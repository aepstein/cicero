class Vote < ActiveRecord::Base
  attr_accessible :rank, :candidate_id

  belongs_to :candidate
  belongs_to :section

  validates_presence_of :candidate
  validates_presence_of :section
  validate :candidate_must_be_in_section_race

  def candidate_must_be_in_section_race
    return unless candidate && section && section.race
    unless section.race.candidates.exists?( candidate.id )
      errors.add :candidate_id, 'is not in the race for this section'
    end
  end

  def to_s
    "vote for #{candidate}"
  end

  def may_user?(user,action)
    case action
      when :index
        ballot.may_user?(user,:show)
    else
      ballot.may_user?(user,action)
    end
  end

  def <=>(aVote)
    return rand<=>rand if rank.nil? && aVote.rank.nil?
    return 1 if rank.nil? && aVote.rank
    return -1 if rank && aVote.rank.nil?
    return rank<=>aVote.rank if rank != aVote.rank
    candidate.name<=>aVote.candidate.name
  end
end

