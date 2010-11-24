require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Roll do
  before(:each) do
    @roll = Factory(:roll)
  end

  after(:each) do
  end

  it "should save with valid properties" do
    @roll.id.should_not be_nil
  end

  it 'should not save without an election' do
    @roll.election = nil
    @roll.save.should eql false
  end

  it 'should not save without name' do
    @roll.name = nil
    @roll.save.should eql false
  end

  it 'should not save with a name unless it is unique for the election' do
    duplicate = Factory.build(:roll, :election => @roll.election)
    duplicate.name = @roll.name
    duplicate.save.should eql false
  end

  it 'should have a users.import_from_string method' do
    existing = Factory(:user)
    @roll.users << existing
    existing_out = Factory(:user, :net_id => 'jd3')
    data = "\"jd1\",\"jd1@example.com\",\"John\",\"Doe\"
\"jd2\",\"jd2@example.com\",\"Jane\",\"Doe\"
\"jd3\",\"jd3@example.com\",\"Third\",\"Person\"
\"#{existing.net_id}\",\"#{existing.email}\",\"#{existing.first_name}\",\"#{existing.last_name}\"
"
    excluded = Factory(:user)
    @roll.users.import_from_string(data).should eql [3,2]
    @roll.users.size.should eql 4
    @roll.users.should_not include excluded
    @roll.users.should include existing
    @roll.users.should include User.find_by_net_id('jd1')
    @roll.users.should include User.find_by_net_id('jd2')
    @roll.users.should include User.find_by_net_id('jd3')
  end

  it 'should have a users.import_from_file method' do
    file = fixture_file_upload 'spec/assets/users.csv','text/csv'
    @roll.users.import_from_file(file).should eql [2,2]
  end

end

