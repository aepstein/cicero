class Candidate < ActiveRecord::Base
  belongs_to :race
  has_many :votes, :dependent => :destroy
  has_many :ballots, :through => :votes
  has_many :petitioners
  has_many :users, :through => :petitioners

  named_scope :disqualified, :conditions => { :disqualified => true }

  has_attached_file :picture, :styles => { :small => '300x300>', :thumb => '100x100>' },
    :path => ':rails_root/db/uploads/:rails_env/candidates/:attachment/:id_partition/:style.:extension',
    :url => '/system/candidates/:attachment/:id_partition/:style.:extension'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :race_id
  validates_attachment_presence :picture
  validates_presence_of :race

  def to_s
    name
  end

  def <=>(other)
    name <=> other.name
  end

  # TODO use to migrate old picture storage to new approach
  def picture_prefix
    "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/candidates/#{race.election_id}/#{race_id}/#{self.id}"
  end

  def may_user?(user,action)
    race.may_user?(user,action)
  end
end

