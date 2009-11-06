class Vote < ActiveRecord::Base
  attr_accessible :rank

  belongs_to :candidate, :include => :race
  belongs_to :ballot

  validates_presence_of :candidate
  validates_presence_of :ballot

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

