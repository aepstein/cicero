class Ballot < ActiveRecord::Base
  attr_accessor :confirmation

  belongs_to :election
  belongs_to :user
  has_many :sections, :dependent => :destroy do
    def with_race_id( race_id )
      to_a.select { |section| section.race_id == race_id }.first
    end
    def populate
      proxy_owner.races.allowed.each do |race|
        section = ( with_race_id(race.id) || build( :race => race ) )
        section.votes.populate
      end
    end
  end
  has_many :races, :through => :election do
    def allowed
      allowed_for_user( proxy_owner.user )
    end
  end

  accepts_nested_attributes_for :sections

  before_validation :initialize_sections

  validates_presence_of :election
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => [ :election_id ]
  validate :sections_must_be_unique

  named_scope :user_contains, lambda { |q|
    q = "%#{q}%"
    { :conditions => ['users.net_id LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?', q, q, q],
      :order => 'users.last_name ASC, users.first_name ASC, users.net_id ASC',
      :include => [ :user ] }
  }

  def sections_must_be_unique
    race_ids = []
    sections.each do |section|
      if section.race_id && race_ids.include?(section.race_id)
        section.errors.add :race_id, 'is not unique for the ballot'
      end
      race_ids << section.race_id if section.race_id?
    end
  end

  def initialize_sections
    sections.each { |section| section.ballot = self if section.ballot.nil? }
  end

  def to_s
    user.to_s
  end

  def may_user?(user,action)
    case action
      when :show
        (self.user == user || user.admin?)
      when :delete
        user.admin? ||
          ( election.managers.include?(user) && Time.now < election.voting_ends_at )
      when :index
        user.admin? || election.managers.include?(user)
      when :create
        self.user == user && user.elections.allowed.include?(election)
    end
  end

end

