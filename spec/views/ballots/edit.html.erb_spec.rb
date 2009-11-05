require 'spec_helper'

describe "/ballots/edit.html.erb" do
  include BallotsHelper

  before(:each) do
    assigns[:ballot] = @ballot = stub_model(Ballot,
      :new_record? => false,
      :election => 1,
      :user => 1
    )
  end

  it "renders the edit ballot form" do
    render

    response.should have_tag("form[action=#{ballot_path(@ballot)}][method=post]") do
      with_tag('input#ballot_election[name=?]', "ballot[election]")
      with_tag('input#ballot_user[name=?]', "ballot[user]")
    end
  end
end
