class AddPictureToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :picture_file_name, :string
    add_column :candidates, :picture_content_type, :string
    add_column :candidates, :picture_file_size, :integer
    add_column :candidates, :picture_updated_at, :datetime
    say_with_time 'Converting candidate pictures to paperclip' do
      Candidate.reset_column_information
      Race.reset_column_information
      Election.reset_column_information
      base = "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/candidates"
      Candidate.all(:include => :race).each do |candidate|
        candidate_base = "#{base}/#{candidate.race.election_id}/#{candidate.race_id}/#{candidate.id}"
        candidate.picture = File.new("#{candidate_base}/original.jpg")
        raise "Could not save candidate: #{candidate.errors.join ', '}" unless candidate.save
      end
      Election.all.each do |election|
        FileUtils.remove_entry_secure "#{base}/#{election.id}" if File.exist? "#{base}/#{election.id}"
      end
    end
  end

  def self.down
    say_with_time 'Regenerating old candidate pictures from paperclip entries' do
      Candidate.reset_column_information
      Race.reset_column_information
      base = "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/candidates"
      Candidate.all(:include => :race).each do |candidate|
        candidate_base = "#{base}/#{candidate.race.election_id}/#{candidate.race_id}/#{candidate.id}"
        FileUtils.mkdir_p candidate_base
        %w( original small thumb )
        FileUtils.mv( candidate.picture.path(style), "#{candidate_base}/" ) if candidate.picture.path(style)
      end
    end
    remove_column :candidates, :picture_updated_at
    remove_column :candidates, :picture_file_size
    remove_column :candidates, :picture_content_type
    remove_column :candidates, :picture_file_name
  end
end

