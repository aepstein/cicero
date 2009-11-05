class Round < ActiveRecord::Base
  belongs_to :race
  has_many :tallies, :dependent => :destroy, :order => 'tally' do
    def exhaustable
      return @exhaustable unless @exhaustable.nil?
      sorted = self.sort
      min = sorted.first.tally
      @exhaustable ||= self.select { |t| t.tally == min }.sort_by { rand }
    end
    def for_candidate(candidate)
      r = self.select { |t| t.candidate == candidate }
      return r[0] unless r.empty?
      nil
    end
  end
  has_many :candidates, :through => :tallies do
    def remaining(force=false)
      @remaining = nil if force
      @remaining ||= Candidate.find_by_sql(
        "SELECT candidates.* FROM candidates WHERE " +
        # Not already exhausted in voting
        #"candidates.id NOT IN (SELECT DISTINCT c.id FROM candidates c, votes v WHERE " +
        #  "c.id=v.candidate_id AND v.exhausted < #{proxy_owner.position}) AND " +
        "candidates.id IN (SELECT DISTINCT c.id FROM candidates c, votes v WHERE " +
          "c.id=v.candidate_id AND " +
            "(v.exhausted IS NULL OR v.exhausted > #{proxy_owner.position})) AND " +
        # Enrolled in the race to which this round belongs
        "candidates.race_id = #{proxy_owner.race_id} AND " +
        # Not disqualified
        "candidates.disqualified = #{proxy_owner.connection.quote(false)}" +
        "ORDER BY candidates.name"
      )
    end
  end
  acts_as_list :scope => :race
  
  after_create :distribute_votes
  before_destroy :scrub_votes

  validates_existence_of :race
  validates_each :race do |record, attr, race|
    record.errors.add( attr, "has not ended yet" ) if race.election.voting_ends_at > Time.now
  end
  
  def may_user?(user,action)
    case action
      when :create, :delete
        user.admin? || election.managers.include?(election)
      when :index, :show
        (race.election.results_available_at < Time.now) || user.admin? || 
          race.election.managers.include?(election)
    end
  end

  protected
  # Distribute votes for this round
  def distribute_votes
    if race.is_ranked?
      Vote.update_all("distributed = #{position}",
                       "votes.id IN " +
                       "(SELECT v.id FROM votes v, candidates c WHERE " +
                         # Belonging to race of which this round is part
                         "v.candidate_id=c.id AND c.race_id=#{race.id} AND " +
                         # Not yet distributed
                         "v.distributed IS NULL AND v.exhausted IS NULL AND " +
                         # Candidate not disqualified
                         "c.disqualified = #{connection.quote(false)} " +
                         # Highest preference on each ballot
                         "GROUP BY v.ballot_id ORDER BY v.rank" +
                       ") AND " +
                       "votes.ballot_id NOT IN " +
                       "(SELECT DISTINCT v.ballot_id FROM votes v, candidates c WHERE " +
                         # Belonging to race of which this round is part
                         "v.candidate_id=c.id AND c.race_id=#{race.id} AND " +
                         # Is distributed and not exhausted
                         "v.distributed < #{position} AND v.exhausted IS NULL" +
                       ")"
                     )
    else
      Vote.update_all("distributed = #{position}",
                      "votes.id IN " +
                        "(SELECT v.id FROM votes v, candidates c WHERE " +
                          # Belonging to race of which this round is part
                          "v.candidate_id=c.id AND c.race_id=#{race.id} AND " +
                          # Not disqualified
                          "c.disqualified = #{connection.quote(false)})" )
    end
    candidates.remaining.each do |candidate|
      tallies.create(:candidate => candidate)
    end
    exhaust_votes if (candidates.remaining.size > race.slots) && race.is_ranked?
  end
  
  # Exhaust votes for this round
  # TODO consider eliminating multiple candidates in a round
  def exhaust_votes
    tally = tallies.exhaustable.first
    Vote.update_all("exhausted=#{position}",
                    "candidate_id=#{tally.candidate.id} AND exhausted IS NULL")
    race.rounds.create
  end
  
  # Undistribute and unexhaust any votes distributed or exhausted after this round
  def scrub_votes
    Vote.update_all("distributed = NULL",
                    "votes.id IN " +
                      "(SELECT v.id FROM votes v, candidates c WHERE " +
                        "v.candidate_id=c.id AND c.race_id=#{race.id} AND " +
                        "distributed >= #{position})")
    Vote.update_all("exhausted = NULL",
                    "votes.id IN " +
                      "(SELECT v.id FROM votes v, candidates c WHERE " +
                        "v.candidate_id=c.id AND c.race_id=#{race.id} AND " +
                        "exhausted >= #{position})")
  end
end