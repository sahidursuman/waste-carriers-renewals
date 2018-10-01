require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "WorldpayForms", type: :request do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_addresses,
                 :has_conviction_search_result,
                 :has_key_people,
                 account_email: user.email,
                 workflow_state: "worldpay_form")
        end
        let(:reg_id) { transient_registration[:reg_identifier] }

        describe "#new" do
          it "redirects to worldpay" do
            VCR.use_cassette("worldpay_redirect") do
              get new_worldpay_form_path(reg_id)
              expect(response.location).to include("https://secure-test.worldpay.com")
            end
          end

          it "creates a new finance_details" do
            VCR.use_cassette("worldpay_redirect") do
              get new_worldpay_form_path(reg_id)
              expect(transient_registration.reload.finance_details).to_not eq(nil)
            end
          end

          context "when there is an error setting up the worldpay url" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:prepare_for_payment).and_return(:error)
            end

            it "redirects to payment_summary_form" do
              get new_worldpay_form_path(reg_id)
              expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
            end
          end
        end

        describe "#success" do
          before do
            FinanceDetails.new_finance_details(transient_registration, :worldpay, user)
          end

          let(:order) do
            transient_registration.finance_details.orders.first
          end

          let(:params) do
            {
              orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
              reg_identifier: reg_id
            }
          end

          context "when the params are valid and the balance is paid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_success?).and_return(true)
              transient_registration.finance_details.update_attributes(balance: 0)
            end

            it "redirects to renewal_complete_form" do
              get success_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_renewal_complete_form_path(reg_id))
            end

            context "when it has been flagged for conviction checks" do
              before do
                transient_registration.conviction_sign_offs = [build(:conviction_sign_off)]
              end

              it "redirects to renewal_received_form" do
                get success_worldpay_forms_path(reg_id), params
                expect(response).to redirect_to(new_renewal_received_form_path(reg_id))
              end
            end
          end

          context "when the params are invalid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_success?).and_return(false)
            end

            it "redirects to payment_summary_form" do
              get success_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
            end
          end

          context "when the orderKey doesn't match an existing order" do
            before do
              params[:orderKey] = "0123456789"
            end

            it "redirects to payment_summary_form" do
              get success_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
            end

            it "does not update the payment" do
              unmodified_payment = transient_registration.finance_details.payments.first
              get success_worldpay_forms_path(reg_id), params
              expect(transient_registration.reload.finance_details.payments.first).to eq(unmodified_payment)
            end
          end
        end

        describe "#pending" do
          before do
            FinanceDetails.new_finance_details(transient_registration, :worldpay, user)
          end

          let(:order) do
            transient_registration.finance_details.orders.first
          end

          let(:params) do
            {
              orderKey: "#{Rails.configuration.worldpay_admin_code}^#{Rails.configuration.worldpay_merchantcode}^#{order.order_code}",
              reg_identifier: reg_id
            }
          end

          context "when the params are valid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_pending?).and_return(true)
            end

            it "redirects to renewal_received_form" do
              get pending_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_renewal_received_form_path(reg_id))
            end
          end

          context "when the params are invalid" do
            before do
              allow_any_instance_of(WorldpayService).to receive(:valid_pending?).and_return(false)
            end

            it "redirects to payment_summary_form" do
              get pending_worldpay_forms_path(reg_id), params
              expect(response).to redirect_to(new_payment_summary_form_path(reg_id))
            end
          end
        end
      end
    end

    describe "#cancel" do
      it_should_behave_like "GET unsuccessful Worldpay response", :cancel
    end

    describe "#error" do
      it_should_behave_like "GET unsuccessful Worldpay response", :error
    end

    describe "#failure" do
      it_should_behave_like "GET unsuccessful Worldpay response", :failure
    end
  end
end
