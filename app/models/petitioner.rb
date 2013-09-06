class Petitioner < ActiveRecord::Base
  SEARCHABLE = [ :user_name_contains ]
  attr_readonly :candidate_id

  belongs_to :user
  belongs_to :candidate

  default_scope includes(:user).
    order('users.last_name ASC, users.first_name ASC, users.net_id ASC')
  scope :user_name_contains, lambda { |name|
    where { |p| p.user_id.in( User.unscoped.name_contains( name ) ) }
  }

  delegate :name, to: :user

  validates :user, presence: true
  validates :user_id, uniqueness: { scope: [ :candidate_id ] }
  validates :candidate, presence: true
  validate :user_must_be_in_race_roll

  def user_must_be_in_race_roll
    return unless candidate && user
    unless candidate.race.roll.users.exists?(user)
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
      self.user = nil
    else
      self.user = User.find_by_net_id name.to_net_ids.first
    end
  end
end

