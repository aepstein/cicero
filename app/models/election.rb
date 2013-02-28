class Election < ActiveRecord::Base
  attr_accessible :name, :starts_at, :ends_at, :results_available_at,
    :verify_message, :contact_name, :contact_email, :rolls_attributes,
    :races_attributes

  has_many :rolls, include: [:races], order: :name,
    dependent: :destroy, inverse_of: :election
  has_many :races, include: [:candidates, :roll], order: :name,
    dependent: :restrict, inverse_of: :election
  has_and_belongs_to_many :managers, class_name: 'User',
    join_table: 'elections_managers'
  has_many :ballots, dependent: :destroy, inverse_of: :election
  has_many :candidates, through: :races

  accepts_nested_attributes_for :rolls, allow_destroy: true
  accepts_nested_attributes_for :races, allow_destroy: true

  scope :ordered, lambda { order { [ starts_at.desc, name ] } }
  scope :allowed_for_user, lambda { |user|
    where { |e| e.id.in( user.rolls.scoped.select { election_id } ) }
  }
  scope :allowable, lambda { where { ends_at > Time.zone.now } }
  scope :past, lambda { where { ends_at < Time.zone.now } }
  scope :current, lambda {
    where { ( starts_at < Time.zone.now ) & ( ends_at > Time.zone.now ) } }
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

  def to_pmwiki(statement_length=1250)
    races.map { |race|
      "(:title #{race.name}:)\n\n" +
      race.candidates.map { |candidate|
        net_id = candidate.name.to_net_ids.first
        if net_id
          name = candidate.name.gsub(/^(.*)\s+\(#{net_id}\)\s*$/,'\1').strip
          heading = candidate.name.gsub(/#{net_id}/,'[[NetId:\0 | \0]]')
          "!!! #{heading}\n" +
          "%rfloat width=\"150px\"% Attach:#{Time.zone.today.year}#{net_id.upcase}.jpg\"Photo of #{name}\"\n\n" +
          candidate.truncated_statement(statement_length)
        else
          "No output for #{candidate.name}\n"
        end
      }.join("\n")
    }.join("\n")
  end

  def past?; ends_at < Time.zone.now; end

  def to_s; name; end

end

