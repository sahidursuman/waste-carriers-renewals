FactoryBot.define do
  factory :check_your_answers_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "check_your_answers_form")) }
    end
  end
end