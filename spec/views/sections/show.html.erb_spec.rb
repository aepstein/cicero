require 'spec_helper'

describe "/sections/show.html.erb" do
  include SectionsHelper
  before(:each) do
    assigns[:section] = @section = stub_model(Section,
      :ballot => 1,
      :race => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end
