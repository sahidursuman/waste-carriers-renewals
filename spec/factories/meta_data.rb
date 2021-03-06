FactoryBot.define do
  factory :metaData, class: WasteCarriersEngine::MetaData do
    trait :has_required_data do
      date_registered { Time.current }
      date_activated { Time.current }
    end
  end
end
