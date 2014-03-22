class Election < ActiveRecord::Base
  has_many :rolls, include: [:races], order: :name,
    dependent: :destroy, inverse_of: :election
  has_many :races, include: [:candidates, :roll], order: :name,
    dependent: :restrict, inverse_of: :election do
    def to_csv
      CSV.generate do |csv|
        csv << %w[ race roll candidate ranked? ]
        each do |race|
          race.candidates.each do |candidate|
            csv << [ race.name, race.roll.name, candidate.name,
              ( race.is_ranked? ? 'Ranked' : 'Checkbox' ) ]
          end
        end
      end
    end
  end
  has_and_belongs_to_many :managers, class_name: 'User',
    join_table: 'elections_managers'
  has_many :ballots, dependent: :destroy, inverse_of: :election
  has_many :sections, through: :ballots
  has_many :votes, through: :sections
  has_many :users, through: :rolls
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
  scope :purgeable, lambda { where { purged_at.eq( nil ) & 
    purge_results_after.lt( Time.zone.today ) } }

  validates :name, presence: true, uniqueness: true
  validates :starts_at, timeliness: { type: :datetime, before: :ends_at }
  validates :ends_at, timeliness: { type: :datetime,
    before: :results_available_at }
  validates :results_available_at, timeliness: { type: :datetime }
  validates :purge_results_after, presence: true
  validates :verify_message, presence: true
  validates :contact_name, presence: true
  validates :contact_email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_nil: false }
  validates_each :purge_results_after do |record, attr, value|
    if value.present? && record.results_available_at? &&
      value.to_time < ( record.results_available_at + 1.month )
      record.errors.add attr,
        'must be at least one month after results available'
    end
  end

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
  
  def unranked_results
    @unranked_results ||= connection.select_rows "SELECT races.name AS race, " +
      "candidates.name AS candidate, COUNT(votes.id) AS vote FROM races INNER " +
      "JOIN candidates ON races.id = candidates.race_id LEFT JOIN votes ON " +
      "candidates.id = votes.candidate_id AND votes.rank = 1 WHERE " +
      "races.is_ranked = 0 AND races.election_id = #{id} GROUP BY candidates.id " +
      "ORDER BY race, vote DESC, candidate"
  end
  
  def unranked_results_csv
    CSV.generate do |csv|
      csv << ["Race", "Candidate", "Vote"]
      unranked_results.each { |row| csv << row }
    end
  end
  
  # Clear sensitive data associated with election (run only after you have captured results!)
  def purge!
    connection.send :delete_sql, "DELETE FROM votes WHERE votes.section_id IN " +
    "(SELECT sections.id FROM sections INNER JOIN ballots ON 
    sections.ballot_id = ballots.id WHERE ballots.election_id = #{id})"
    connection.send :delete_sql, "DELETE FROM sections WHERE ballot_id IN " +
    "(SELECT id FROM ballots WHERE ballots.election_id = #{id})"
    connection.send :delete_sql, "DELETE FROM rolls_users WHERE roll_id IN " +
    "(SELECT id FROM rolls WHERE election_id = #{id})"
    update_column :purged_at, Time.zone.now
  end

  def to_s(format=nil)
    return super() if name.blank?
    case format
    when :file
      name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-')
    else
      name
    end
  end

end

