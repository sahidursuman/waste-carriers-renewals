require 'rails_helper'

RSpec.describe "registrations/show", type: :view do
  before(:each) do
    @registration = assign(:registration, Registration.create!(
      :reg_identifier => "Reg Identifier",
      :company_name => "Company Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Reg Identifier/)
    expect(rendered).to match(/Company Name/)
  end
end