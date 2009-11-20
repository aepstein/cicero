class Petitioner < ActiveRecord::Base
  belongs_to :user
  belongs_to :candidate

  delegate :name, :to => :user
  delegate :net_id, :to => :user

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
    user.name
  end

  def may_user?(user,action)
    candidate.may_user?(user,action)
  end

  def net_id=(net_id)
     self.user = User.find(:first, :conditions => { :net_id => net_id[/^(\w{2,3}\d{1,4})/] } )
  end
end

