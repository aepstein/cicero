require 'spec_helper'

describe Section, :type => :model do
  before(:each) do
    @section = create(:section)
  end

  it "should create a new instance given valid attributes" do
    expect(@section.id).not_to be_nil
  end

  it 'should not save without a ballot specified' do
    @section.ballot = nil
    expect(@section.save).to eql false
  end

  it 'should not save without a race specified' do
    @section.race = nil
    expect(@section.save).to eql false
  end

  it 'should not save with a duplicate race within a given ballot' do
    duplicate = build(:section, :ballot => @section.ballot, :race => @section.race)
    expect(duplicate.save).to eql false
  end

  it "should not save with a race whose roll does not include the ballot's user" do
    race = create(:race, :election => @section.ballot.election)
    expect(race.roll.users.exists?(@section.ballot.user.id)).to be false
    @section.race = race
    expect(@section.save).to eql false
  end

  it "should have a votes.populate method that generates votes for each candidate" do
    excluded = create(:candidate, :race => create( :race, :election => @section.ballot.election ) )
    included = add_candidate_for_section( @section )
    @section.reload
    @section.votes.populate
    expect(@section.votes.size).to eql 1
    candidates = @section.votes.map { |vote| vote.candidate }
    expect(candidates).to include included
    expect(candidates).not_to include excluded
  end

  it 'should not save duplicate ranks in a ranked race' do
    @section = build(:section)
    @section.race.update_attributes :slots => 3, :is_ranked => true
    3.times { add_candidate_for_section @section }
    3.times { |i| @section.votes.build( :candidate_id => @section.race.candidates[i].id,
      :rank => (i+1) ) }
    @section.votes.last.rank = 2
    expect(@section.votes.map(&:rank)).to eql [1,2,2]
    expect(@section.save).to be false
  end

  it 'should not save votes for which there is no immediately lower rank in a ranked race' do
    @section = build(:section)
    @section.race.update_attributes :slots => 3, :is_ranked => true
    3.times { add_candidate_for_section @section }
    2.times { |i| @section.votes.build( :candidate_id => @section.race.candidates[i].id,
      :rank => (i+1) ) }
    @section.votes.last.rank = 3
    expect(@section.votes.map(&:rank)).to eql [1,3]
    expect(@section.save).to be false
  end

  def add_candidate_for_section( section )
    create( :candidate, :race => section.race )
  end
end

