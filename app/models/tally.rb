class Tally < ActiveRecord::Base
  belongs_to :round
  belongs_to :candidate
  before_validation_on_create :set_tally

  validates_presence_of :round
  validates_presence_of :candidate
  validates_numericality_of :tally

  protected
  # Tally votes for candidate in this round
  def set_tally
    self.tally=Vote.count_by_sql(
      "SELECT COUNT(*) FROM votes v " +
      # Count votes that were distributed by this round
      "WHERE candidate_id=#{candidate_id} AND distributed <= #{round.position} " +
      # Count only votes that are not exhausted or are exhausted at or after this round
      "AND (exhausted IS NULL OR exhausted >= #{round.position})"
    )
  end

  def <=>(other)
    tally <=> other.tally
  end

  def may_user?(user,action)
    round.may_user?(user,action)
  end
end

