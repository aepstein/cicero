class Election < ActiveRecord::Base
  attr_accessible :name, :starts_at, :ends_at, :results_available_at, :verify_message,
    :contact_name, :contact_email

  has_many :rolls, :include => [:races], :order => :name, :dependent => :destroy,
    :inverse_of => :election
  has_many :races, :include => [:candidates, :roll], :order => :name,
    :dependent => :destroy, :inverse_of => :election
  has_and_belongs_to_many :managers, :class_name => 'User', :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy, :inverse_of => :election
  has_many :candidates, :through => :races

  default_scope order('elections.name ASC')

  scope :allowed_for_user_id, lambda { |user_id|
    where(
      'elections.id IN (SELECT election_id FROM rolls AS r INNER JOIN rolls_users AS ru ' +
      'WHERE r.id = ru.roll_id AND ru.user_id = ?)',
      user_id )
  }
  scope :allowable, lambda { where( :ends_at.gt => Time.zone.now )}
  scope :past, lambda { where( :ends_at.lt => Time.zone.now ) }
  scope :current, lambda { where( :starts_at.lt => Time.zone.now, :ends_at.gt => Time.zone.now ) }
  scope :future, lambda { where( :starts_at.gt => Time.zone.now ) }

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

