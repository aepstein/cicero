require 'spec_helper'

describe Roll do
  before(:each) do
    @roll = Factory(:roll)
  end

  it "should save with valid properties" do
    @roll.id.should_not be_nil
  end

  it 'should not save without an election' do
    @roll.election = nil
    @roll.save.should eql false
  end

  it 'should not save without name' do
    @roll.name = nil
    @roll.save.should eql false
  end

  it 'should not save with a name unless it is unique for the election' do
    duplicate = Factory.build(:roll, :election => @roll.election)
    duplicate.name = @roll.name
    duplicate.save.should eql false
  end

end

