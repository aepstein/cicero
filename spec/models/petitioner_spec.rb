require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Petitioner do
  before(:each) do
    @petitioner = Factory(:petitioner)
  end

  it "should save with valid properties" do
    @petitioner.id.should_not be_nil
  end

  it 'should not save without a user' do
    @petitioner.user = nil
    @petitioner.save.should eql false
  end

  it 'should not save without a candidate' do
    @petitioner.candidate = nil
    @petitioner.save.should eql false
  end

  it 'should not save if the user is not in the roll of the candidate\'s race' do
    outside = Factory(:user)
    @petitioner.candidate.race.roll.users.should_not include outside
    @petitioner.user = outside
    @petitioner.save.should eql false
  end

  it 'should not save a duplicate user id for the same candidate' do
    duplicate = Factory.build(:petitioner, :user => @petitioner.user, :candidate => @petitioner.candidate )
    duplicate.save.should eql false
  end

  it 'should return user\'s name when converted to string' do
    @petitioner.to_s.should eql @petitioner.user.name
  end

end

