class Petitioner < ActiveRecord::Base
  belongs_to :user
  belongs_to :candidate

  default_scope includes(:user).order('users.last_name ASC, users.first_name ASC, users.net_id ASC')
  scope :user_name_contains, lambda { |name|
    self & User.name_like( name )
  }

  search_methods :user_name_contains

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

  def user_name
    "#{user.name} (#{user.net_id})" if user
  end

  def user_name=(name)
    if name.to_net_ids.empty?
      self.user = User.find_by_net_id name[/\(([^\s]*)\)/,1]
    end
    self.user = nil if user && user.id.blank?
  end
end

