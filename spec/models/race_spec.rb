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

  it 'should not save to a different roll if any linked candidates are in a different race' do
    election = @race.election
    old_roll = @race.roll
    new_roll = Factory(:roll, :election => election )
    [
      { :external => true, :internal => true, :valid => false, :linked_race_ids => 2 },
      { :external => true, :internal => false, :valid => false, :linked_race_ids => 1 },
      { :external => false, :internal => true, :valid => true, :linked_race_ids => 1 },
      { :external => false, :internal => false, :valid => true, :linked_race_ids => 0 }
    ].each do |scenario|
      candidate = Factory(:candidate, :race => Factory(:race, :election => election, :roll => old_roll) )
      if scenario[:external]
        external = add_externally_linked_candidate(candidate)
      else
        external = false
      end
      if scenario[:internal]
        internal = add_internally_linked_candidate(candidate)
      else
        internal = false
      end
      race = Race.find(candidate.race.id)
      race.roll = new_roll
      race.linked_race_ids.size.should eql scenario[:linked_race_ids]
      race.save.should eql scenario[:valid]
    end
  end

  def add_externally_linked_candidate(candidate)
    external = Factory(:race, :election => candidate.race.election, :roll => candidate.race.roll)
    external_candidate = Factory(:candidate, :race => external, :linked_candidate => candidate)
  end

  def add_internally_linked_candidate(candidate)
    linked_candidate = Factory(:candidate, :race => candidate.race, :linked_candidate => candidate)
  end

  after(:each) do
    Candidate.all.each { |c| c.destroy }
  end

end

