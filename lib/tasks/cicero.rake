namespace :cicero do

  desc "Purge elections"
  task :purge => [ :environment ] do
    Election.purgeable.each do |election|
      election.purge!
      cicero_log "Purged election #{election.id}."
    end
  end
  
  def cicero_log(message)
    ::Rails.logger.info "rake at #{Time.zone.now}: cicero: #{message}"
    ::Rails.logger.flush
  end

end

