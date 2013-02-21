class Candidate < ActiveRecord::Base
  attr_accessible :name, :eliminated, :statement, :disqualified, :picture,
    :_destroy
  attr_readonly :race_id

  belongs_to :race, inverse_of: :candidates
  has_many :votes, inverse_of: :candidate, dependent: :destroy
  has_many :sections, through: :votes
  has_many :petitioners, inverse_of: :candidate
  has_many :users, through: :petitioners

  scope :disqualified, where( disqualified: true )

  mount_uploader :picture, PortraitUploader

  validates :name, presence: true, uniqueness: { scope: :race_id }
  validates :race, presence: true

  def truncated_statement(chars)
    n = 0
    statement.chars.inject("") do |memo, char|
      n += 1 unless char =~ /\s/
      if n > chars
        memo
      else
        memo << char
      end
    end
  end

  def to_s
    return "New candidate" if new_record?
    name? ? name : super
  end

  def <=>(other); name <=> other.name; end

end

