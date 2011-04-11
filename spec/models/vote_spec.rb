require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Vote do
  before(:each) do
    @vote = Factory(:vote)
  end

  it "should save with valid properties" do
    @vote.id.should_not be_nil
  end

  it "should not save without a candidate" do
    @vote.candidate = nil
    @vote.save.should be_false
  end

  it 'should not save without a section' do
    @vote.section = nil
    @vote.save.should be_false
  end

  it 'should not save without a rank' do
    @vote.rank = nil
    @vote.save.should be_false
  end


end

