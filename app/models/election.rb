class Election < ActiveRecord::Base
  named_scope :allowable, lambda { { :conditions => [ 'elections.voting_ends_at > ?', DateTime.now ] } }
  
  has_many :rolls, :include => [:races], :order => :name, :dependent => :destroy
  has_many :races, :include => [:candidates, :roll], :order => :name, :dependent => :destroy do
    def open_to(user)
      user.races.select { |r| r.election == proxy_owner }
    end
  end
  has_and_belongs_to_many :managers,
                          :class_name => 'User',
                          :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy do
    def for_user(user)
      @for_user ||= self.find(:first,
                              :conditions => [ 'ballots.election_id = ? AND ballots.user_id = ?',
                                               proxy_owner.id, user.id ],
                              :limit => 1)
    end
    def for_race(race)
      @for_race ||= self.find(:all,
                              :include => [ :votes ],
                              :conditions => [ 'votes.candidate_id IN (SELECT candidates.id FROM candidates WHERE candidates.race_id = ?) AND cast_at IS NOT NULL', race.id ],
                              :order => 'ballots.id ASC, votes.rank ASC')
    end
    def uncast_size
      @uncast_size ||= Ballot.count(
        :conditions => "election_id = #{proxy_owner.id} AND cast_at IS NULL"
      )
    end
    def cast_size
      @cast_size ||= Ballot.count( 
        :conditions => "election_id = #{proxy_owner.id} AND cast_at IS NOT NULL"
      )
    end
  end
  has_many :candidates, :through => :races
  
  validates_presence_of :name
  validates_presence_of :voting_starts_at
  validates_presence_of :voting_ends_at
  validates_presence_of :results_available_at
  validates_uniqueness_of :name
  validates_each :voting_ends_at, :allow_nil => true do |record, attr, value|
    unless record.voting_starts_at.nil? || record.voting_starts_at < value
      record.errors.add( attr, "must occur after voting starts" )
    end
  end
  validates_each :results_available_at, :allow_nil => true do |record, attr, value|
    unless record.voting_ends_at.nil? || record.voting_ends_at < value
      record.errors.add( attr, "must occur after voting ends" )
    end
  end
  validates_presence_of :contact_name
  validates_presence_of :contact_info
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => false
  
  # Marks and tabulates votes for all races
  def tabulate
    return false if Time.now < voting_ends_at # TODO is this an appropriate place for this?
    races.each do |race|
      race.rounds.create if race.rounds.size == 0
    end
    self.tabulated_at = Time.now
    save
    true
  end
  
  # Scrubs tabulated results and unmarks votes for all races
  def untabulate
    races.each do |race|
      race.scrub_rounds
    end
    self.tabulated_at = nil
    save
  end
  
  def past?
    voting_ends_at < DateTime.now
  end
  
  def to_s
    name
  end
  
  def may_user?(user,action)
    case action
      when :create, :update, :delete
        user.admin?
      when :show, :index
        return true if user.admin? || self.managers.include?(user)
        self.voting_starts_at < Time.now
      when :tabulate
        return true if tabulated_at.nil? && user.admin? && (voting_ends_at < Time.now)
    end
  end
end
