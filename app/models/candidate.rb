class Candidate < ActiveRecord::Base
  attr_accessible :name, :eliminated, :statement, :disqualified, :picture
  attr_readonly :race_id

  belongs_to :race, :inverse_of => :candidates
  has_many :votes, :inverse_of => :candidate, :dependent => :destroy
  has_many :sections, :through => :votes
  has_many :petitioners, :inverse_of => :candidate
  has_many :users, :through => :petitioners

  scope :disqualified, where( :disqualified => true )

  has_attached_file :picture, :styles => { :small => '300x300>', :thumb => '100x100>' },
    :path => ':rails_root/db/uploads/:rails_env/candidates/:attachment/:id_partition/:style.:extension',
    :url => '/system/candidates/:attachment/:id_partition/:style.:extension'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :race_id
  validates_presence_of :race

  def to_s; name; end

  def <=>(other); name <=> other.name; end

end

