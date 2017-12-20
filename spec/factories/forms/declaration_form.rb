FactoryBot.define do
  factory :declaration_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "declaration_form")) }
    end
  end
end