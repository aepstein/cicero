require 'spec_helper'

describe Candidate do
  before(:each) do
    @candidate = Factory(:candidate)
  end

  it "should save with valid properties" do
    @candidate.id.should_not be_nil
  end

  it 'should not save without a race' do
    @candidate.race = nil
    @candidate.save.should eql false
  end

  it 'should not save without a name' do
    @candidate.name = nil
    @candidate.save.should eql false
  end

  it 'should not save with a name unless it is unique for the race' do
    duplicate = Factory.build(:candidate, :race => @candidate.race)
    duplicate.name = @candidate.name
    duplicate.save.should eql false
  end

  it 'should only save a linked candidate only if it is in a race with same roll as this candidate' do
    candidates = linked_candidate_samples
    { :invalid => false, :other => false, :valid => true }.each do |candidate, valid|
      @candidate.linked_candidate = candidates[candidate]
      @candidate.save.should eql valid
    end
  end

  it 'should have a linked_candidates.possible method that returns candidates under same roll (excluding the instant candidate)' do
    candidates = linked_candidate_samples
    @candidate.linked_candidates.possible.size.should eql 1
    @candidate.linked_candidates.possible.should include candidates[:valid]
  end

  it 'should have a linked_race_ids method that returns ids of externally related races' do
    external = add_externally_linked_candidate(@candidate)
    @candidate.linked_race_ids.size.should eql 1
    @candidate.linked_race_ids.should include external.race_id
    external.linked_race_ids.size.should eql 1
    external.linked_race_ids.should include @candidate.race_id
  end

  it 'should have a linked_race_ids method that returns ids of internally related races' do
    internal = add_internally_linked_candidate(@candidate)
    @candidate.linked_race_ids.size.should eql 1
    @candidate.linked_race_ids.should include internal.race_id
    internal.linked_race_ids.size.should eql 1
    internal.linked_race_ids.should include @candidate.race_id
  end

  def linked_candidate_samples
    invalid_race = Factory(:race, :election => @candidate.race.election)
    invalid_candidate = Factory(:candidate, :race => invalid_race)
    valid_race = Factory(:race, :election => @candidate.race.election, :roll => @candidate.race.roll)
    valid_candidate = Factory(:candidate, :race => valid_race)
    other_candidate = Factory(:candidate)
    { :invalid => invalid_candidate, :valid => valid_candidate, :other => other_candidate }
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

