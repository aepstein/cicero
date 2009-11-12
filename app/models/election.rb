class Election < ActiveRecord::Base
  named_scope :allowable, lambda { { :conditions => [ 'elections.voting_ends_at > ?', DateTime.now ] } }

  scope_procedure :past, lambda { voting_ends_at_less_than DateTime.now.utc }
  scope_procedure :current, lambda { voting_starts_at_less_than(DateTime.now.utc).voting_ends_at_greater_than(DateTime.now.utc) }
  scope_procedure :future, lambda { voting_starts_at_greater_than(DateTime.now.utc) }

  has_many :rolls, :include => [:races], :order => :name, :dependent => :destroy
  has_many :races, :include => [:candidates, :roll], :order => :name, :dependent => :destroy do
    def open_to(user)
      user.races.select { |race| race.election_id == proxy_owner.election_id }
    end
  end
  has_and_belongs_to_many :managers, :class_name => 'User', :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy do
    def for_user(user)
      user_id_equals( user.id ).first
    end
  end
  has_many :candidates, :through => :races

  validates_presence_of :name
  validates_datetime :voting_starts_at, :before => :voting_ends_at
  validates_datetime :voting_ends_at, :before => :results_available_at
  validates_presence_of :results_available_at
  validates_uniqueness_of :name
  validates_presence_of :verify_message
  validates_presence_of :contact_name
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

