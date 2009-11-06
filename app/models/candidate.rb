require 'fileutils'
require 'RMagick'

class Candidate < ActiveRecord::Base
  belongs_to :race
  has_many :votes, :dependent => :destroy
  has_many :ballots, :through => :votes
  has_many :petitioners
  has_many :users, :through => :petitioners
  has_many :linked_candidates,
           :class_name => 'Candidate',
           :foreign_key => 'linked_candidate_id',
           :include => :race,
           :dependent => :nullify do
             def possible
               proxy_owner.race.roll.candidates.reject { |c| c == proxy_owner }
             end
           end
  belongs_to :linked_candidate,
             :class_name => 'Candidate'

  named_scope :disqualified, :conditions => { :disqualified => true }

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :race_id
  validates_presence_of :picture,
                        :unless => :picture?,
                        :message => 'may not be blank if candidate does not have a picture on file'
  validates_presence_of :race

  def validate
    candidate.errors.add(
      attribute,
      "must be a JPEG file"
    ) if picture.methods.include?('content_type') && picture.content_type != 'image/jpeg'
  end

  def to_s
    name
  end

  def <=>(other)
    name <=> other.name
  end

  after_save :write_picture
  after_destroy :destroy_picture

  def picture_path(which=:original)
    path="#{picture_prefix}/#{which}.jpg"
    return path if File.exist?(path)
  end

  def picture
    @picture
  end

  def picture=(picture_data)
    @picture = picture_data
  end

  def write_picture
    unless picture.is_a? String
      logger.info "mkdir -p #{picture_prefix}"
      FileUtils.makedirs(picture_prefix)
      logger.info "write #{picture_prefix}"
      File.open("#{picture_prefix}/original.jpg",'wb') do |file|
        file.write(picture.read)
      end
      original = Magick::Image.read(picture_path(:original)).first
      logger.info "write #{picture_prefix}/small.jpg"
      original.resize_to_fit(300,300).write("#{picture_prefix}/small.jpg")
      logger.info "write #{picture_prefix}/thumb.jpg"
      original.resize_to_fit(100,100).write("#{picture_prefix}/thumb.jpg")
    end
  end

  def destroy_picture
    FileUtils.rm_rf(picture_prefix)
  end

  def picture_prefix
    "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/candidates/#{race.election.id}/#{race.id}/#{self.id}"
  end

  def picture?
    return false unless picture_path
    true
  end

  def may_user?(user,action)
    race.may_user?(user,action)
  end
end

