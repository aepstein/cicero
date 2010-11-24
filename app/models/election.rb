class Election < ActiveRecord::Base
  has_many :rolls, :include => [:races], :order => :name, :dependent => :destroy
  has_many :races, :include => [:candidates, :roll], :order => :name, :dependent => :destroy
  has_and_belongs_to_many :managers, :class_name => 'User', :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy
  has_many :candidates, :through => :races

  default_scope order('elections.name ASC')

  scope :allowed_for_user_id, lambda { |user_id|
    where(
      'elections.id IN (SELECT election_id FROM rolls AS r INNER JOIN rolls_users AS ru ' +
      'WHERE r.id = ru.roll_id AND ru.user_id = ?)',
      user_id )
  }
  scope :allowable, lambda { ends_at_greater_than Time.zone.now }
  scope :past, lambda { ends_at_less_than Time.zone.now }
  scope :current, lambda { starts_at_less_than(Time.zone.now).ends_at_greater_than(Time.zone.now) }
  scope :future, lambda { starts_at_greater_than(Time.zone.now) }

  validates_presence_of :name
  validates_datetime :starts_at, :before => :ends_at
  validates_datetime :ends_at, :before => :results_available_at
  validates_presence_of :results_available_at
  validates_uniqueness_of :name
  validates_presence_of :verify_message
  validates_presence_of :contact_name
  validates_format_of :contact_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_nil => false

  def past?; ends_at < Time.zone.now; end

  def to_s; name; end

end

