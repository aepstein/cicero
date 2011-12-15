class Election < ActiveRecord::Base
  attr_accessible :name, :starts_at, :ends_at, :results_available_at,
    :verify_message, :contact_name, :contact_email

  has_many :rolls, :include => [:races], :order => :name,
    :dependent => :destroy, :inverse_of => :election
  has_many :races, :include => [:candidates, :roll], :order => :name,
    :dependent => :destroy, :inverse_of => :election
  has_and_belongs_to_many :managers, :class_name => 'User',
    :join_table => 'elections_managers'
  has_many :ballots, :dependent => :destroy, :inverse_of => :election
  has_many :candidates, :through => :races

  default_scope order('elections.name ASC')

  scope :allowed_for_user_id, lambda { |user_id|
    where(
      'elections.id IN (SELECT election_id FROM rolls AS r INNER JOIN rolls_users AS ru ' +
      'WHERE r.id = ru.roll_id AND ru.user_id = ?)',
      user_id )
  }
  scope :allowable, lambda { where { ends_at > Time.zone.now } }
  scope :past, lambda { where { ends_at < Time.zone.now } }
  scope :current, lambda {
    where { starts_at < Time.zone.now && ends_at > Time.zone.now } }
  scope :future, lambda { where { starts_at > Time.zone.now } }

  validates :name, presence: true, uniqueness: true
  validates :starts_at, timeliness: { type: :datetime, before: :ends_at }
  validates :ends_at, timeliness: { type: :datetime,
    before: :results_available_at }
  validates :results_available_at, timeliness: { type: :datetime }
  validates :verify_message, presence: true
  validates :contact_name, presence: true
  validates :contact_email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_nil: false }

  def past?; ends_at < Time.zone.now; end

  def to_s; name; end

end

