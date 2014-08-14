require 'spec_helper'

describe Petitioner, :type => :model do
  before(:each) do
    @petitioner = create(:petitioner)
  end

  it "should save with valid properties" do
    expect(@petitioner.id).not_to be_nil
  end

  it 'should not save without a user' do
    @petitioner.user = nil
    expect(@petitioner.save).to eql false
  end

  it 'should not save without a candidate' do
    @petitioner.candidate = nil
    expect(@petitioner.save).to eql false
  end

  it 'should not save if the user is not in the roll of the candidate\'s race' do
    outside = create(:user)
    expect(@petitioner.candidate.race.roll.users).not_to include outside
    @petitioner.user = outside
    expect(@petitioner.save).to eql false
  end

  it 'should not save a duplicate user id for the same candidate' do
    duplicate = build(:petitioner, :user => @petitioner.user, :candidate => @petitioner.candidate )
    expect(duplicate.save).to eql false
  end

  it 'should return user\'s name when converted to string' do
    expect(@petitioner.to_s).to eql @petitioner.user.name
  end

end

