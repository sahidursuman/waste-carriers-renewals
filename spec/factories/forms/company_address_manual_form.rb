FactoryBot.define do
  factory :company_address_manual_form, class: WasteCarriersEngine::CompanyAddressManualForm do
    trait :has_required_data do
      house_number { "Business Building" }
      address_line_1 { "Foo Terrace" }
      address_line_2 { "Bar Street" }
      town_city { "Bazville" }
      postcode { "12345" }
      country { "FooBarBaz" }

      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "company_address_manual_form")) }
    end
  end
end
