require 'spec_helper'

describe Election do
  before(:each) do
    @election = create(:election)
  end

  it "should create a new instance given valid attributes" do
    @election.id.should_not be_nil
  end

  it "should not save without a name" do
    @election.name = nil
    @election.save.should eql false
  end

  it "should not save without a unique name" do
    duplicate = build(:election)
    duplicate.name = @election.name
    duplicate.save.should eql false
  end

  it "should not save without starts_at" do
    @election.starts_at = nil
    @election.save.should eql false
  end

  it "should not save with start date at or after end date" do
    @election.starts_at = @election.ends_at
    @election.save.should eql false
    @election.starts_at += 1.days
    @election.save.should eql false
  end

  it "should not save without ends_at" do
    @election.ends_at = nil
    @election.save.should eql false
  end
  
  it "should not save without results_available_at" do
    @election.results_available_at = nil
    @election.save.should be_false
  end
  
  it "should not save with invalid results_available_at" do
    @election.results_available_at = @election.ends_at - 5.minutes
    @election.save.should be_false
  end
  
  it "should not save without purge_results_after" do
    @election.purge_results_after = nil
    @election.save.should be_false
  end
  
  it "should not save with invalid purge_results_after" do
    @election.purge_results_after = @election.results_available_at + 3.weeks
    @election.save.should be_false
  end

  it "should not save without contact name" do
    @election.contact_name = nil
    @election.save.should eql false
  end

  it "should not save without a contact email" do
    @election.contact_email = nil
    @election.save.should eql false
  end

  it "should not save with a badly formed contact email" do
    @election.contact_email = 'bad'
    @election.save.should eql false
  end

  it "should not save without verify message" do
    @election.verify_message = nil
    @election.save.should eql false
  end

  it "should have an allowable scope showing elections ending after today" do
    make_past_and_future
    Election.allowable.size.should eql 2
    Election.allowable.should include @election
    Election.allowable.should include @future
  end

  it 'should have a past scope' do
    make_past_and_future
    Election.past.size.should eql 1
    Election.past.should include @past
  end

  it 'should have a current scope' do
    make_past_and_future
    Election.current.size.should eql 1
    Election.current.should include @election
  end

  it 'should have a future scope' do
    make_past_and_future
    Election.future.size.should eql 1
    Election.future.should include @future
  end

  it 'should have a past? method' do
    make_past_and_future
    @past.past?.should eql true
    @election.past?.should eql false
    @future.past?.should eql false
  end
  
  it "should have a working purge method" do
    @election = create(:vote).section.ballot.election
    other = create(:vote).section.ballot.election
    @election.votes.count.should > 0
    @election.users.count.should > 0
    @election.purge!
    @election.votes.count.should eql 0
    @election.users.count.should eql 0
    other.votes.count.should > 0
    other.users.count.should > 0
  end
  
  it "should have a purgeable method" do
    make_past_and_future
    Election.purgeable.length.should eql 1
    Election.purgeable.should include @past
  end

  def make_past_and_future
    @past = create(:past_election)
    @future = create(:future_election)
  end
end

