require 'spec_helper'

describe "/sections/edit.html.erb" do
  include SectionsHelper

  before(:each) do
    assigns[:section] = @section = stub_model(Section,
      :new_record? => false,
      :ballot => 1,
      :race => 1
    )
  end

  it "renders the edit section form" do
    render

    response.should have_tag("form[action=#{section_path(@section)}][method=post]") do
      with_tag('input#section_ballot[name=?]', "section[ballot]")
      with_tag('input#section_race[name=?]', "section[race]")
    end
  end
end
