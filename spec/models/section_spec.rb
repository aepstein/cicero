require 'spec_helper'

describe Section do
  before(:each) do
    @section = Factory(:section)
  end

  it "should create a new instance given valid attributes" do
    @section.id.should_not be_nil
  end

  it 'should not save without a ballot specified' do
    @section.ballot = nil
    @section.save.should eql false
  end

  it 'should not save without a race specified' do
    @section.race = nil
    @section.save.should eql false
  end

  it 'should not save with a duplicate race within a given ballot' do
    duplicate = Factory.build(:section, :ballot => @section.ballot, :race => @section.race)
    duplicate.save.should eql false
  end

  it "should not save with a race whose roll does not include the ballot's user" do
    race = Factory(:race, :election => @section.ballot.election)
    race.roll.users.exists?(@section.ballot.user.id).should be_false
    @section.race = race
    @section.save.should eql false
  end
end

