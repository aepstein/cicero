require 'spec_helper'

describe Election do
  before(:each) do
    @race = Factory(:race)
  end

  it "should save a race with valid properties" do
    @race.id.should_not be_nil
  end

end

