require 'spec_helper'

describe Election do
  before(:each) do
    @race = Factory(:race)
  end

  it "should save a race with valid properties" do
    @race.id.should_not be_nil
  end

  it 'should not save without an election' do
    @race.election = nil
    @race.save.should eql false
  end

  it 'should not save without a name' do
    @race.name = nil
    @race.save.should eql false
  end

  it 'should not save if the name duplicates another in the same election' do
    duplicate = Factory.build(:race, :election => @race.election)
    duplicate.name = @race.name
    duplicate.save.should eql false
  end

  it 'should not save without number of slots specified' do
    @race.slots = nil
    @race.save.should eql false
  end

  it 'should not save with invalid number of slots specified' do
    @race.slots = 0
    @race.save.should eql false
    @race.slots = 'not number'
    @race.save.should eql false
    @race.slots = 2.2
    @race.save.should eql false
  end

  xit 'should not save unless is_ranked is specified' do
    @race.is_ranked = nil
    @race.save.should eql false
  end

  it 'should not save without a roll' do
    @race.roll = nil
    @race.save.should eql false
  end

  it 'should not save with a roll from a different election' do
    @race.roll = Factory(:roll)
    @race.election.rolls.should_not include @race.roll
    @race.save.should eql false
  end

end

