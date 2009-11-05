require 'spec_helper'

describe "/ballots/index.html.erb" do
  include BallotsHelper

  before(:each) do
    assigns[:ballots] = [
      stub_model(Ballot,
        :election => 1,
        :user => 1
      ),
      stub_model(Ballot,
        :election => 1,
        :user => 1
      )
    ]
  end

  it "renders a list of ballots" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
