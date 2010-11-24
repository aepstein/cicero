require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

  def make_past_and_future
    @past = Factory(:past_election)
    @future = Factory(:future_election)
  end
end

