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

end

