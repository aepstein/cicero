class Election < ActiveRecord::Base
  named_scope :allowable, lambda { { :conditions => [ 'elections.voting_ends_at > ?', DateTime.now ] } }
  named_scope :allowed_for_user_id, lambda { |user_id|
    { :conditions => [
        'elections.id IN (SELECT election_id FROM rolls AS r INNER JOIN rolls_users AS ru
        WHERE r.id = ru.roll_id AND ru.user_id = ?)',
        user_id ] }
  }
  scope_procedure :past, lambda { voting_ends_at_less_than DateTime.now.utc }
  scope_procedure :current, lambda { voting_starts_at_less_than(DateTime.now.utc).voting_ends_at_greater_than(DateTime.now.utc) }
  scope_procedure :future, lambda { voting_starts_at_greater_than(DateTime.now.utc) }

  has_many :rolls, :include => [:races], :order => :name, :dependent => :destroy
  has_many :races, :include => [:candidates, :roll], :order => :name, :dependent => :destroy
  has_and_belongs_to_many :managers, :class_name => 'User', :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy
  has_many :candidates, :through => :races

  validates_presence_of :name
  validates_datetime :voting_starts_at, :before => :voting_ends_at
  validates_datetime :voting_ends_at, :before => :results_available_at
  validates_presence_of :results_available_at
  validates_uniqueness_of :name
  validates_presence_of :verify_message
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => false

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

