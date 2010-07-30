class Race < ActiveRecord::Base
  named_scope :allowed_for_user_id, lambda { |user_id|
    { :joins => 'INNER JOIN rolls_users AS ru',
      :conditions => [ 'races.roll_id = ru.roll_id AND ru.user_id = ?', user_id ] }
  }

  belongs_to :election
  belongs_to :roll
  has_many :candidates, :order => 'candidates.name ASC', :dependent => :destroy do
    def open_to(user)
      self.reject { |c| user.candidates.include?(c) }
    end
  end
  has_many :sections
  has_many :ballots, :through => :sections

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :election_id
  validates_presence_of :election
  validates_numericality_of :slots, :only_integer => true, :greater_than => 0
  validates_presence_of :roll
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
    case format
    when :file
      self.name.strip.downcase.gsub(/[^a-z]/,'-').squeeze('-') + ".blt"
    else
      name
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
    sections.all(:include => :votes).each do |section|
      section.race = self
      output += "1 #{section.to_blt} 0\r\n"
    end
    output += "0\r\n"
    candidates.each do |candidate|
      output += "\"#{candidate.name}\"\r\n"
    end
    output += "\"#{name}\""
    return output
  end
end

