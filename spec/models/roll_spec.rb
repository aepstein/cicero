require 'spec_helper'

describe Roll, :type => :model do
  before(:each) do
    @roll = create(:roll)
  end

  after(:each) do
  end

  it "should save with valid properties" do
    expect(@roll.id).not_to be_nil
  end

  it 'should not save without an election' do
    @roll.election = nil
    expect(@roll.save).to eql false
  end

  it 'should not save without name' do
    @roll.name = nil
    expect(@roll.save).to eql false
  end

  it 'should not save with a name unless it is unique for the election' do
    duplicate = build(:roll, :election => @roll.election)
    duplicate.name = @roll.name
    expect(duplicate.save).to eql false
  end

  it 'should have a users.import_from_string method' do
    existing = create(:user)
    @roll.users << existing
    existing_out = create(:user, :net_id => 'jd3')
    data = "\"jd1\",\"jd1@example.com\",\"John\",\"Doe\"
\"jd2\",\"jd2@example.com\",\"Jane\",\"Doe\"
\"jd3\",\"jd3@example.com\",\"Third\",\"Person\"
\"#{existing.net_id}\",\"#{existing.email}\",\"#{existing.first_name}\",\"#{existing.last_name}\"
"
    excluded = create(:user)
    expect(@roll.users.import_from_string(data)).to eql [3,2]
    expect(@roll.users.size).to eql 4
    expect(@roll.users).not_to include excluded
    expect(@roll.users).to include existing
    expect(@roll.users).to include User.find_by_net_id('jd1')
    expect(@roll.users).to include User.find_by_net_id('jd2')
    expect(@roll.users).to include User.find_by_net_id('jd3')
  end

  it 'should have a users.import_from_file method' do
    file = Rack::Test::UploadedFile.new(
      "#{::Rails.root}/spec/assets/users.csv",'text/csv' )
    expect(@roll.users.import_from_file(file)).to eql [2,2]
  end

end

