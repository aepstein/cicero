require 'spec_helper'

describe "/ballots/new.html.erb" do
  include BallotsHelper

  before(:each) do
    assigns[:ballot] = stub_model(Ballot,
      :new_record? => true,
      :election => 1,
      :user => 1
    )
  end

  it "renders new ballot form" do
    render

    response.should have_tag("form[action=?][method=post]", ballots_path) do
      with_tag("input#ballot_election[name=?]", "ballot[election]")
      with_tag("input#ballot_user[name=?]", "ballot[user]")
    end
  end
end
