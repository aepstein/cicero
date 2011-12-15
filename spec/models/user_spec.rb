require 'spec_helper'

describe User do
  before(:each) do
    @user = create(:user)
  end

  it "should save with valid properties" do
    @user.id.should_not be_nil
  end

  it 'should not save without a net_id' do
    @user.net_id = nil
    @user.save.should eql false
  end

  it 'should not save a user with duplicate net_id' do
    duplicate = build(:user, :net_id => @user.net_id)
    duplicate.save.should eql false
  end

  it 'should not save without a first name' do
    @user.first_name = nil
    @user.save.should eql false
  end

  it 'should not save without a last name' do
    @user.last_name = nil
    @user.save.should eql false
  end

  it 'should not save without an email' do
    @user.email = nil
    @user.save.should eql false
  end

  it "should not save with a badly formed email" do
    @user.email = 'bad'
    @user.save.should eql false
  end

end

