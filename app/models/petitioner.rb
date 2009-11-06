class Petitioner < ActiveRecord::Base
  belongs_to :user
  belongs_to :candidate

  validates_presence_of :user
  validates_presence_of :candidate
  validates_uniqueness_of :user_id,
                          :scope => :candidate_id,
                          :message => "has already petitioned for candidate"

  def validate
    errors.add( :user,
                "#{value} is not eligible to petition for #{petitioner.candidate}"
              ) unless candidate.race.roll.users.find(user.id)
  end

  def may_user?(user,action)
    candidate.may_user?(user,action)
  end

  def name
    user.name
  end

  def net_id
    user.net_id unless user.nil?
  end

  def net_id=(net_id)
     self.user = User.find(:first, :conditions => { :net_id => net_id[/^(\w{2,3}\d{1,4})/] } )
  end
end

