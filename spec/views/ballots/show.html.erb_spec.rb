require 'spec_helper'

describe "/ballots/show.html.erb" do
  include BallotsHelper
  before(:each) do
    assigns[:ballot] = @ballot = stub_model(Ballot,
      :election => 1,
      :user => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end
