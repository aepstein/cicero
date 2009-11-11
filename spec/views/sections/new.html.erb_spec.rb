require 'spec_helper'

describe "/sections/new.html.erb" do
  include SectionsHelper

  before(:each) do
    assigns[:section] = stub_model(Section,
      :new_record? => true,
      :ballot => 1,
      :race => 1
    )
  end

  it "renders new section form" do
    render

    response.should have_tag("form[action=?][method=post]", sections_path) do
      with_tag("input#section_ballot[name=?]", "section[ballot]")
      with_tag("input#section_race[name=?]", "section[race]")
    end
  end
end
