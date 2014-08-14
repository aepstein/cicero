require 'spec_helper'

describe Candidate, :type => :model do
  before(:each) do
    @candidate = create(:candidate)
  end

  it "should save with valid properties" do
    expect(@candidate.id).not_to be_nil
  end

  it 'should not save without a race' do
    @candidate.race = nil
    expect(@candidate.save).to eql false
  end

  it 'should not save without a name' do
    @candidate.name = nil
    expect(@candidate.save).to eql false
  end

  it 'should not save with a name unless it is unique for the race' do
    duplicate = build(:candidate, :race => @candidate.race)
    duplicate.name = @candidate.name
    expect(duplicate.save).to eql false
  end

  it 'should have a disqualified named scope that gets only disqualified canidates' do
    expect(@candidate.disqualified).to eql false
    disqualified = create(:candidate, :disqualified => true)
    expect(Candidate.disqualified.size).to eql 1
    expect(Candidate.disqualified).to include disqualified
  end

  after(:each) do
    Candidate.all.each { |c| c.destroy }
  end

end

