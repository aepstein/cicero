require 'spec_helper'

describe Election, :type => :model do
  let(:race) { build(:race) }

  it "should save a race with valid properties" do
    race.save!
  end

  it 'should not save without an election' do
    race.election = nil
    expect(race.save).to eql false
  end

  it 'should not save without a name' do
    race.name = nil
    expect(race.save).to eql false
  end

  it 'should not save if the name duplicates another in the same election' do
    race.save!
    duplicate = build(:race, election: race.election)
    duplicate.name = race.name
    expect(duplicate.save).to eql false
  end

  it 'should not save without number of slots specified' do
    race.slots = nil
    expect(race.save).to eql false
  end

  it 'should not save with invalid number of slots specified' do
    race.slots = 0
    expect(race.save).to eql false
    race.slots = 'not number'
    expect(race.save).to eql false
    race.slots = 2.2
    expect(race.save).to eql false
  end

  it 'should not save without a roll' do
    race.roll = nil
    expect(race.save).to eql false
  end

  it 'should not save with a roll from a different election' do
    race.roll = create(:roll)
    expect(race.election.rolls).not_to include race.roll
    expect(race.save).to eql false
  end

  context "to_blt" do

    let(:race) { create(:race, is_ranked: true) }
    let(:ballot) { create(:ballot, election: race.election ) }
    let(:section) { race.roll.users << ballot.user; create(:section, ballot: ballot, race: race) }
    let(:top) { create(:candidate, name: "Top", race: race) }
    let(:middle) { create(:candidate, name: "Middle", race: race) }
    let(:bottom) { create(:candidate, name: "Bottom", race: race) }
    before(:each) do
      top; middle; bottom
      race.reload
      section.votes << build(:vote, rank: 1, candidate: top)
      section.votes << build(:vote, rank: 2, candidate: middle)
      section.votes << build(:vote, rank: 3, candidate: bottom)
      section.save!
      race.reload
    end

    it "should return correct data with disqualified candidate" do
      middle.update_column :disqualified, true
      lines = race.to_blt.split "\r\n"
      expect(lines[0]).to eql "3 1" # "number of candidates, number of seats"
      expect(lines[1]).to eql "-2" # "disqualified candidate"
      expect(lines[2]).to eql "1 3 1 0" # ballot itself "1 [indices of candidates] 0"
      expect(lines[3]).to eql "0" # end of ballots
      expect(lines[4]).to eql "\"Bottom\""
      expect(lines[5]).to eql "\"Middle\""
      expect(lines[6]).to eql "\"Top\""
      expect(lines[7]).to eql "\"#{race.name}\""
    end

    it "should return correct data without disqualified candidate" do
      lines = race.to_blt.split "\r\n"
      expect(lines[0]).to eql "3 1"
      expect(lines[1]).to eql "1 3 2 1 0"
    end
  end

end

