require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "BankTransferForms", type: :request do
    include_examples "GET locked-in form", form = "bank_transfer_form"

    describe "GET new_bank_transfer_form" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "bank_transfer_form")
          end

          it "creates a new order" do
            get new_bank_transfer_form_path(transient_registration[:reg_identifier])
            expect(transient_registration.reload.finance_details.orders.count).to eq(1)
          end

          context "when a worldpay order already exists" do
            before do
              FinanceDetails.new_finance_details(transient_registration, :worldpay, user)
              transient_registration.finance_details.orders.first.world_pay_status = "CANCELLED"
            end

            it "replaces the old order" do
              get new_bank_transfer_form_path(transient_registration[:reg_identifier])
              expect(transient_registration.reload.finance_details.orders.first.world_pay_status).to eq(nil)
            end

            it "does not increase the order count" do
              old_order_count = transient_registration.finance_details.orders.count
              get new_bank_transfer_form_path(transient_registration[:reg_identifier])
              expect(transient_registration.reload.finance_details.orders.count).to eq(old_order_count)
            end
          end
        end
      end
    end

    include_examples "POST without params form", form = "bank_transfer_form"

    describe "GET back_bank_transfer_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "bank_transfer_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the payment_summary form" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_payment_summary_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   :has_unpaid_balance,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_bank_transfer_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
