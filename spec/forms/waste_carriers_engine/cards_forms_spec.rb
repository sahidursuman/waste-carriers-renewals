require "rails_helper"

module WasteCarriersEngine
  RSpec.describe CardsForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: cards_form.reg_identifier,
            temp_cards: cards_form.temp_cards
          }
        end

        it "should submit" do
          expect(cards_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:cards_form) { build(:cards_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(cards_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:cards_form) { build(:cards_form, :has_required_data) }

      describe "#temp_cards" do
        context "when a temp_cards meets the requirements" do
          it "is valid" do
            expect(cards_form).to be_valid
          end
        end

        context "when a temp_cards is blank" do
          before(:each) do
            cards_form.temp_cards = ""
          end

          it "is valid" do
            expect(cards_form).to be_valid
          end
        end

        context "when a temp_cards is not a number" do
          before(:each) do
            cards_form.temp_cards = "foo"
          end

          it "is not valid" do
            expect(cards_form).to_not be_valid
          end
        end

        context "when a temp_cards is not an integer" do
          before(:each) do
            cards_form.temp_cards = 3.14
          end

          it "is not valid" do
            expect(cards_form).to_not be_valid
          end
        end

        context "when a temp_cards is a negative number" do
          before(:each) do
            cards_form.temp_cards = -3
          end

          it "is not valid" do
            expect(cards_form).to_not be_valid
          end
        end
      end
    end
  end
end
