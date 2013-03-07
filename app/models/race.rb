class Race < ActiveRecord::Base
  attr_accessible :name, :slots, :is_ranked, :roll_id, :description,
    :candidates_attributes, :_destroy
  attr_readonly :election_id

  belongs_to :election, inverse_of: :races
  belongs_to :roll, inverse_of: :races
  has_many :candidates, order: 'candidates.name ASC', dependent: :destroy,
    inverse_of: :race do
    def open_to(user)
      self.reject { |c| user.candidates.include?(c) }
    end
    def to_blt_map
      inject({}) do |memo, c|
        memo[ c.id ] = to_a.index(c) + 1
        memo
      end
    end
  end
  has_many :sections, inverse_of: :race, dependent: :restrict do
    def to_blt_values
      disqualified = proxy_association.owner.candidates.disqualified.map(&:id)
      sql = "SELECT sections.id, votes.rank, votes.candidate_id FROM " +
        "sections LEFT JOIN votes ON sections.id = votes.section_id " +
        ( disqualified.any? ? "AND votes.candidate_id NOT IN (#{connection.quote disqualified}) " : "" ) +
        "WHERE sections.race_id = #{proxy_association.owner.id} " +
        "ORDER BY sections.id ASC, votes.rank ASC"
      last_section_id = nil
      candidates_map = proxy_association.owner.candidates.to_blt_map
      connection.select_rows( sql ).inject([]) do |memo, vote|
        if last_section_id == vote.first
          memo.last << candidates_map[ vote.last ]
          memo
        else
          last_section_id = vote.first
          memo << [ candidates_map[ vote.last ] ]
        end
      end
    end
  end
  has_many :ballots, through: :sections

  accepts_nested_attributes_for :candidates, allow_destroy: true

  scope :allowed_for_user, lambda { |user|
    where { |r| r.roll_id.in( user.rolls.scoped.select { id } ) }
  }

  validates :name, presence: true, uniqueness: { scope: :election_id }
  validates :election, presence: true
  validates :slots, numericality: { only_integer: true, greater_than: 0 }
  validates :roll, presence: true
  validate :roll_must_belong_to_election

  def roll_must_belong_to_election
    return unless election && roll_id?
    unless election.rolls.exists? roll_id
      errors.add :roll_id, 'must be part of the election to which this race belongs.'
    end
  end

  def max_votes
    return slots unless candidates.size < slots || is_ranked?
    candidates.size
  end

  def rank_options
    1..max_votes
  end

  def available_slots
    return slots if slots < candidates.size
    candidates.size
  end

  def to_s(format = nil)
    return "New race" if new_record?
    case format
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-') + ".blt"
    else
      name? ? name : super()
    end
  end

  def <=>(otherRace)
    name <=> otherRace.name
  end

  # Provide blt output
  def to_blt
    output = "#{candidates.size} #{slots}\r\n"
    candidates.disqualified.each do |candidate|
      output += "-#{candidates.index(candidate) + 1}\r\n"
    end
    sections.to_blt_values.each do |section|
      output += "1 #{section.join " "} 0\r\n".squeeze(" ")
    end
#    sections.includes(:votes).all.each do |section|
#      section.race = self
#      output += "1 #{section.to_blt} 0\r\n"
#    end
    output += "0\r\n"
    candidates.each do |candidate|
      output += "\"#{candidate.name}\"\r\n"
    end
    output += "\"#{name}\""
    return output
  end
end

