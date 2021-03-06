require "rails_helper"

module WasteCarriersEngine
  RSpec.describe PaymentSummaryForm, type: :model do
    describe "#submit" do
      context "when the form is valid" do
        let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: payment_summary_form.reg_identifier,
            temp_payment_method: payment_summary_form.temp_payment_method
          }
        end

        it "should submit" do
          expect(payment_summary_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(payment_summary_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:payment_summary_form) { build(:payment_summary_form, :has_required_data) }

      describe "#temp_payment_method" do
        context "when a temp_payment_method meets the requirements" do
          it "is valid" do
            expect(payment_summary_form).to be_valid
          end
        end

        context "when a temp_payment_method is blank" do
          before(:each) do
            payment_summary_form.reg_identifier = ""
          end

          it "is not valid" do
            expect(payment_summary_form).to_not be_valid
          end
        end

        context "when a temp_payment_method not an allowed string" do
          before(:each) do
            payment_summary_form.reg_identifier = "foo"
          end

          it "is not valid" do
            expect(payment_summary_form).to_not be_valid
          end
        end
      end
    end
  end
end
