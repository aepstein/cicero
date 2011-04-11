class Section < ActiveRecord::Base
  attr_accessor :warning

  belongs_to :ballot, :inverse_of => :sections
  belongs_to :race
  has_many :votes, :inverse_of => :section, :dependent => :destroy,
    :order => 'votes.rank' do
    def populate
      proxy_owner.race.candidates.each do |candidate|
        build(:candidate => candidate) unless candidate_ids.include? candidate.id
      end
    end
    def candidate_ids
      map { |vote| vote.candidate_id }
    end
    def ranks
      map { |vote| vote.rank }
    end
  end

  validates_presence_of :ballot
  validates_presence_of :race
  validates_uniqueness_of :race_id, :scope => [ :ballot_id ]
  validate :user_must_be_in_race_roll, :votes_must_not_exceed_maximum,
    :sections_must_be_unique

  accepts_nested_attributes_for :votes, :reject_if => proc { |a| a['rank'].to_i == 0 }

  def to_blt
    votes.collect { |vote| race.candidate_ids.index(vote.candidate_id) + 1 }.join(' ')
  end

  protected

  def user_must_be_in_race_roll
    return unless race && ballot
    unless race.roll.users.exists?(ballot.user_id)
      errors.add :race_id, 'does not have the user in its roll'
    end
  end

  def sections_must_be_unique
    return unless race && ballot
    races = ballot.sections.reject { |section| section === self }.map(&:race)
    if races.include? race
      errors.add :race_id, 'duplicates a race id specified elsewhere in the ballot'
    end
  end

  def votes_must_not_exceed_maximum
    return unless race
    over = votes.size - race.max_votes
    if over > 0
      errors.add :base, "#{over} votes are selected beyond the #{race.max_votes} that are allowed for the race #{race.name}"
    elsif over < 0
      self.warning = "#{over.abs} fewer votes are selected than the #{race.max_votes} that are allowed for the race #{race.name}"
    end
  end

end

