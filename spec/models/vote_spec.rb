require 'spec_helper'

describe Vote, :type => :model do
  before(:each) do
    @vote = create(:vote)
  end

  it "should save with valid properties" do
    expect(@vote.id).not_to be_nil
  end

  it "should not save without a candidate" do
    @vote.candidate = nil
    expect(@vote.save).to be false
  end

  it 'should not save without a section' do
    @vote.section = nil
    expect(@vote.save).to be false
  end

  it 'should not save without a rank' do
    @vote.rank = nil
    expect(@vote.save).to be false
  end


end

