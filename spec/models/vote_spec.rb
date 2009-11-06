require 'spec_helper'

describe Vote do
  before(:each) do
    @vote = Factory(:vote)
  end

  it "should save with valid properties" do
    @vote.id.should_not be_nil
  end

  it "should not save without a candidate" do
    @vote.candidate = nil
    @vote.save.should eql false
  end

  it 'should not save without a ballot' do
    @vote.ballot = nil
    @vote.save.should eql false
  end


end

