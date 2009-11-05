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

  it "should not save without voting_starts_at" do
    @election.voting_starts_at = nil
    @election.save.should eql false
  end

  it "should not save with start date at or after end date" do
    @election.voting_starts_at = @election.voting_ends_at
    @election.save.should eql false
    @election.voting_starts_at += 1.days
    @election.save.should eql false
  end

  it "should not save without voting_ends_at" do
    @election.voting_ends_at = nil
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

  it "should not save without contact info" do
    @election.contact_info = nil
    @election.save.should eql false
  end

  it "should not save without verify message" do
    @election.verify_message = nil
    @election.save.should eql false
  end
end

