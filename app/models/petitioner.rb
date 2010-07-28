class Petitioner < ActiveRecord::Base
  default_scope :include => :user, :order => 'users.last_name ASC, users.first_name ASC, users.net_id ASC'
  belongs_to :user
  belongs_to :candidate

  delegate :name, :to => :user

  validates_presence_of :user
  validates_presence_of :candidate
  validates_uniqueness_of :user_id, :scope => [ :candidate_id ]
  validate :user_must_be_in_race_roll

  def user_must_be_in_race_roll
    return unless candidate && user_id
    unless candidate.race.roll.users.exists?(user_id)
      errors.add :user_id, "is not eligible to petition for #{candidate}"
    end
  end

  def to_s
    user.name if user
  end

  def net_id
    user.net_id if user
  end

  def net_id=(net_id)
    return self.user = nil if net_id.nil? || net_id.blank?
    self.user = User.find_by_net_id net_id[/^(\w{2,4}\d+)/]
  end
end

