FactoryBot.define do
  factory :register_in_northern_ireland_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "register_in_northern_ireland_form")) }
    end
  end
end