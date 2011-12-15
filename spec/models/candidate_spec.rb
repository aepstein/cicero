require 'spec_helper'

describe Candidate do
  before(:each) do
    @candidate = create(:candidate)
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
    duplicate = build(:candidate, :race => @candidate.race)
    duplicate.name = @candidate.name
    duplicate.save.should eql false
  end

  it 'should have a disqualified named scope that gets only disqualified canidates' do
    @candidate.disqualified.should eql false
    disqualified = create(:candidate, :disqualified => true)
    Candidate.disqualified.size.should eql 1
    Candidate.disqualified.should include disqualified
  end

  after(:each) do
    Candidate.all.each { |c| c.destroy }
  end

end

