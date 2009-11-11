require 'spec_helper'

describe "/sections/index.html.erb" do
  include SectionsHelper

  before(:each) do
    assigns[:sections] = [
      stub_model(Section,
        :ballot => 1,
        :race => 1
      ),
      stub_model(Section,
        :ballot => 1,
        :race => 1
      )
    ]
  end

  it "renders a list of sections" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
