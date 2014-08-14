require 'spec_helper'

describe Ballot, :type => :model do
  before(:each) do
    @ballot = create(:ballot)
  end

  it "should save with valid properties" do
    expect(@ballot.id).not_to be_nil
  end

  it 'should not save without an election' do
    @ballot.election = nil
    expect(@ballot.save).to eql false
  end

  it 'should not save without a user' do
    @ballot.user = nil
    expect(@ballot.save).to eql false
  end

  it 'should not save if another ballot exists for same user and election' do
    duplicate = build(:ballot, :user => @ballot.user, :election => @ballot.election)
    expect(duplicate.save).to eql false
  end

  it 'should generate correct votes for a race and save' do
    ballot = build(:ballot)
    race = add_race_for_ballot( ballot, :is_ranked => false )
    candidate_a = add_candidate_for_race race
    candidate_b = add_candidate_for_race race
    ballot.sections_attributes = [ {
      'race_id' => race.id,
      'votes_attributes' => [ {
        'candidate_id' => "#{candidate_a.id}", 'rank' => '1'
      } ]
    } ]
    expect(ballot.save).to eql true
    expect(ballot.sections.size).to eql 1
    section = ballot.sections.first
    expect(section.race).to eql race
    expect(section.votes.size).to eql 1
    expect(section.votes.first.candidate).to eql candidate_a
    expect(section.votes.first.rank).to eql 1
  end

  it "should have a races.allowed method that returns only races the user is allowed to vote in" do
    allowed = add_race_for_ballot(@ballot)
    not_allowed = create(:race, :election => @ballot.election)
    expect(allowed).not_to eql not_allowed
    expect(@ballot.races.allowed.size).to eq(1)
    expect(@ballot.races.allowed).to include allowed
    expect(@ballot.races).to include not_allowed
  end

  it 'should have a confirmation accessor method' do
    expect(@ballot.confirmation).to be_nil
    @ballot.confirmation = true
    expect(@ballot.confirmation).to eql true
  end

  it 'should have sections.with_race_id method that returns a section with a particular race_id' do
    first_race = add_race_for_ballot( @ballot )
    second_race = add_race_for_ballot( @ballot )
    second_section = @ballot.sections.build( :race_id => second_race.id )
    first_section = @ballot.sections.build( :race_id => first_race.id )
    expect(@ballot.sections.with_race_id( first_race.id ).race).to eql first_race
  end

  it 'should have a sections.populate method that creates sections for each race the user can vote in' do
    allowed_race = add_race_for_ballot( @ballot )
    disallowed_race = create(:race, :election => @ballot.election)
    @ballot.reload
    @ballot.sections.populate
    expect(@ballot.sections.size).to eql 1
    expect(@ballot.sections.map { |section| section.race }).to include allowed_race
  end

  def add_race_for_ballot(ballot, options = {})
    ballot.association(:sections).reset
    default_options = { :election => ballot.election, :roll => create(:roll, :election => ballot.election) }
    race = create(:race, default_options.merge(options) )
    race.roll.users << ballot.user
    race
  end

  def add_candidate_for_race(race, options = {})
    default_options = { :race => race }
    create(:candidate, default_options.merge(options) )
  end

end

