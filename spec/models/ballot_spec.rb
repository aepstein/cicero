require 'spec_helper'

describe Ballot do
  before(:each) do
    @ballot = Factory(:ballot)
  end

  it "should save with valid properties" do
    @ballot.id.should_not be_nil
  end

  it 'should not save without an election' do
    @ballot.election = nil
    @ballot.save.should eql false
  end

  it 'should not save without a user' do
    @ballot.user = nil
    @ballot.save.should eql false
  end

  it 'should not save if another ballot exists for same user and election' do
    duplicate = Factory.build(:ballot, :user => @ballot.user, :election => @ballot.election)
    duplicate.save.should eql false
  end

  it 'should generate correct votes for a race and save' do
    ballot = Factory.build(:ballot)
    race = add_race_for_ballot( ballot, :is_ranked => false )
    candidate_a = add_candidate_for_race race
    candidate_b = add_candidate_for_race race
    ballot.votes_attributes = [ { 'candidate_id' => "#{candidate_a.id}", 'rank' => '1' } ]
    ballot.save.should eql true
    ballot.votes.size.should eql 1
    ballot.votes.first.candidate.should eql candidate_a
    ballot.votes.first.rank.should eql 1
  end

  def add_race_for_ballot(ballot, options = {})
    default_options = { :election => ballot.election, :roll => Factory(:roll, :election => ballot.election) }
    race = Factory(:race, default_options.merge(options) )
    race.roll.users << ballot.user
    race
  end

  def add_candidate_for_race(race, options = {})
    default_options = { :race => race }
    Factory(:candidate, default_options.merge(options) )
  end

end
