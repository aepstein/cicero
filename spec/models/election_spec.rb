require 'spec_helper'

describe Election do
  before(:each) do
    @election = Factory(:election)
  end

  it "should create a new instance given valid attributes" do
    @election.id.should_not be_nil
  end

  it "should not save without a name" do
    @election.name = nil
    @election.save.should eql false
  end

  it "should not save without a unique name" do
    duplicate = Factory.build(:election)
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
    past = Factory(:past_election)
    current = @election
    future = Factory(:future_election)
    Election.allowable.size.should eql 2
    Election.allowable.should include current
    Election.allowable.should include future
  end
end

