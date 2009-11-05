class Race < ActiveRecord::Base
  belongs_to :election
  belongs_to :roll
  has_many :candidates,
           :include => [:linked_candidates, :linked_candidate],
           :order => 'candidates.name ASC',
           :dependent => :destroy do
    def open_to(user)
      self.reject { |c| user.candidates.include?(c) }
    end
  end
  has_many :votes, :through => :candidates, :uniq => true
  has_many :rounds,  :dependent => :destroy, :order => 'position'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :election_id
  validates_existence_of :election
  validates_presence_of :slots
  validates_numericality_of :slots,
                            :only_integer => true,
                            :message => 'is not an integer'

  def max_votes
    return slots unless candidates.size < slots || is_ranked?
    candidates.size
  end
  
  def rank_options
    1..max_votes
  end
  
  def may_user?(user, action)
    case action
      when :create, :update, :delete
        user.admin? || (election.voting_starts_at > Time.now && election.managers.include?(user))
    else
      election.may_user?(user, action)
    end
  end
  
  def available_slots
    return slots if slots < candidates.size
    candidates.size
  end

  def to_s
    name
  end
  
  def <=>(otherRace)
    name <=> otherRace.name
  end
  
  # Delete rounds for race
  def scrub_rounds
    rounds.reverse_each do |round|
      round.destroy
    end
  end
  
  # Provide blt output
  def to_blt
    output = "#{candidates.size} #{slots}\n"
    candidates.disqualified.each do |candidate|
      output += "-#{candidates.index(candidate)}\n"
    end
    election.ballots.for_race(self).each do |ballot|
      output += "1 #{ballot.to_blt(self)} 0\n"
    end
    output += "0\n"
    candidates.each do |candidate|
      output += "\"#{candidate.name}\"\n"
    end
    output += "\"#{name}\""
    return output
  end
end