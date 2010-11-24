ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def setup_elections
    @elections ||= {}
    @elections[:current] = elections(:current)
    @elections[:past] = elections(:past)
    @elections[:future] = elections(:future)
    @users ||= {}
    @users[:public] ||= User.find_or_create_by_net_id('pub1')
    @users[:manager] ||= User.find_or_create_by_net_id('man1')
    @users[:voter] ||= User.find_or_create_by_net_id('usr1')
    @users[:admin] ||= User.find_or_create_by_net_id('adm1')
    @users[:admin].admin=true
    @users[:admin].save
    @races ||= {}
    @candidates ||= {}
    @ballots ||= {}
    @rolls ||= {}
    @elections.each do |key, election|
      @rolls[key] = election.rolls.find_or_create_by_name('Test roll')
      @races[key] = election.races.create( :name => 'Test race', :roll => election.rolls.first )
      @races[key].roll.users<<@users[:voter] unless @races[key].roll.users.include?(@users[:voter])
      @candidates[key] = @races[key].candidates.find_or_create_by_name( 'Test Candidate' )
      election.managers<<@users[:manager] unless election.managers.include?(@users[:manager])
      @ballots[key] = election.ballots.create( :user => @users[:voter] )
    end
  end

  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
     end
    return t
  end
end

