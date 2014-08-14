require 'spec_helper'

describe User, :type => :model do
  before(:each) do
    @user = create(:user)
  end

  it "should save with valid properties" do
    expect(@user.id).not_to be_nil
  end

  it 'should not save without a net_id' do
    @user.net_id = nil
    expect(@user.save).to eql false
  end

  it 'should not save a user with duplicate net_id' do
    duplicate = build(:user, :net_id => @user.net_id)
    expect(duplicate.save).to eql false
  end

  it 'should not save without a first name' do
    @user.first_name = nil
    expect(@user.save).to eql false
  end

  it 'should not save without a last name' do
    @user.last_name = nil
    expect(@user.save).to eql false
  end

  it 'should not save without an email' do
    @user.email = nil
    expect(@user.save).to eql false
  end

  it "should not save with a badly formed email" do
    @user.email = 'bad'
    expect(@user.save).to eql false
  end

end

