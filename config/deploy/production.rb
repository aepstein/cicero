role :app, "kvm02.assembly.cornell.edu"
role :web, "kvm02.assembly.cornell.edu"
role :db,  "kvm02.assembly.cornell.edu", primary: true

server 'kvm02.assembly.cornell.edu', user: 'www-data', roles: %w{web app db}
set :deploy_via, :remote_cache

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


