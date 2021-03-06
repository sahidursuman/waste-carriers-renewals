require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ConvictionSearchResult, type: :model do
    describe "new_from_entity_matching_service" do
      context "when given data from the entity matching service" do
        let(:data) do
          {
            "match_result" => "YES",
            "matching_system" => "PQR",
            "reference" => "7766",
            "matched_name" => "Test Waste Services Ltd.",
            "searched_at" => 4815162342,
            "confirmed" => "no",
            "confirmed_at" => nil,
            "confirmed_by" => nil
          }
        end
        let(:conviction_sign_off) { ConvictionSearchResult.new_from_entity_matching_service(data) }

        it "assigns the correct value to match_result" do
          expect(conviction_sign_off.match_result).to eq(data["match_result"])
        end

        it "assigns the correct value to matching_system" do
          expect(conviction_sign_off.matching_system).to eq(data["matching_system"])
        end

        it "assigns the correct value to reference" do
          expect(conviction_sign_off.reference).to eq(data["reference"])
        end

        it "assigns the correct value to matched_name" do
          expect(conviction_sign_off.matched_name).to eq(data["matched_name"])
        end

        it "assigns the correct value to searched_at" do
          expected_datetime = DateTime.new(1970, 2, 25, 17, 32, 42)
          expect(conviction_sign_off.searched_at).to eq(expected_datetime)
        end

        it "assigns the correct value to confirmed" do
          expect(conviction_sign_off.confirmed).to eq(data["confirmed"])
        end
      end
    end
  end
end
