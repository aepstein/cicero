require 'spec_helper'

describe Election, :type => :model do
  before(:each) do
    @election = create(:election)
  end

  it "should create a new instance given valid attributes" do
    expect(@election.id).not_to be_nil
  end

  it "should not save without a name" do
    @election.name = nil
    expect(@election.save).to eql false
  end

  it "should not save without a unique name" do
    duplicate = build(:election)
    duplicate.name = @election.name
    expect(duplicate.save).to eql false
  end

  it "should not save without starts_at" do
    @election.starts_at = nil
    expect(@election.save).to eql false
  end

  it "should not save with start date at or after end date" do
    @election.starts_at = @election.ends_at
    expect(@election.save).to eql false
    @election.starts_at += 1.days
    expect(@election.save).to eql false
  end

  it "should not save without ends_at" do
    @election.ends_at = nil
    expect(@election.save).to eql false
  end
  
  it "should not save without results_available_at" do
    @election.results_available_at = nil
    expect(@election.save).to be false
  end
  
  it "should not save with invalid results_available_at" do
    @election.results_available_at = @election.ends_at - 5.minutes
    expect(@election.save).to be false
  end
  
  it "should not save without purge_results_after" do
    @election.purge_results_after = nil
    expect(@election.save).to be false
  end
  
  it "should not save with invalid purge_results_after" do
    @election.purge_results_after = @election.results_available_at + 3.weeks
    expect(@election.save).to be false
  end

  it "should not save without contact name" do
    @election.contact_name = nil
    expect(@election.save).to eql false
  end

  it "should not save without a contact email" do
    @election.contact_email = nil
    expect(@election.save).to eql false
  end

  it "should not save with a badly formed contact email" do
    @election.contact_email = 'bad'
    expect(@election.save).to eql false
  end

  it "should not save without verify message" do
    @election.verify_message = nil
    expect(@election.save).to eql false
  end

  it "should have an allowable scope showing elections ending after today" do
    make_past_and_future
    expect(Election.allowable.size).to eql 2
    expect(Election.allowable).to include @election
    expect(Election.allowable).to include @future
  end

  it 'should have a past scope' do
    make_past_and_future
    expect(Election.past.size).to eql 1
    expect(Election.past).to include @past
  end

  it 'should have a current scope' do
    make_past_and_future
    expect(Election.current.size).to eql 1
    expect(Election.current).to include @election
  end

  it 'should have a future scope' do
    make_past_and_future
    expect(Election.future.size).to eql 1
    expect(Election.future).to include @future
  end

  it 'should have a past? method' do
    make_past_and_future
    expect(@past.past?).to eql true
    expect(@election.past?).to eql false
    expect(@future.past?).to eql false
  end
  
  it "should have a working purge method" do
    @election = create(:vote).section.ballot.election
    other = create(:vote).section.ballot.election
    expect(@election.votes.count).to be > 0
    expect(@election.users.count).to be > 0
    @election.purge!
    expect(@election.votes.count).to eql 0
    expect(@election.users.count).to eql 0
    expect(other.votes.count).to be > 0
    expect(other.users.count).to be > 0
  end
  
  it "should have a purgeable method" do
    make_past_and_future
    expect(Election.purgeable.length).to eql 1
    expect(Election.purgeable).to include @past
  end

  def make_past_and_future
    @past = create(:past_election)
    @future = create(:future_election)
  end
end

