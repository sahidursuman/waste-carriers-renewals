require "rails_helper"

module WasteCarriersEngine
  RSpec.describe TransientRegistration, type: :model do
    describe "#workflow_state" do
      context "when a TransientRegistration's state is :worldpay_form" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 :has_conviction_search_result,
                 :has_key_people,
                 :has_paid_balance,
                 workflow_state: "worldpay_form")
        end

        it "changes to :payment_summary_form after the 'back' event" do
          expect(transient_registration).to transition_from(:worldpay_form).to(:payment_summary_form).on_event(:back)
        end

        context "when a conviction check is not required" do
          before do
            transient_registration.conviction_sign_offs = nil
          end

          context "when the balance is 0" do
            it "changes to :renewal_complete_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_complete_form).on_event(:next)
            end

            it "does not send a confirmation email after the 'next' event" do
              old_emails_sent_count = ActionMailer::Base.deliveries.count
              transient_registration.next!
              expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count)
            end
          end

          context "when there is a positive balance" do
            before do
              transient_registration.finance_details.balance = 100
            end

            it "changes to :renewal_received_form after the 'next' event" do
              expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
            end

            it "sends a confirmation email after the 'next' event" do
              old_emails_sent_count = ActionMailer::Base.deliveries.count
              transient_registration.next!
              expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count + 1)
            end
          end
        end

        context "when a conviction check is required" do
          before do
            transient_registration.conviction_sign_offs = [build(:conviction_sign_off)]
          end

          it "changes to :renewal_received_form after the 'next' event" do
            expect(transient_registration).to transition_from(:worldpay_form).to(:renewal_received_form).on_event(:next)
          end

          it "sends a confirmation email after the 'next' event" do
            old_emails_sent_count = ActionMailer::Base.deliveries.count
            transient_registration.next!
            expect(ActionMailer::Base.deliveries.count).to eq(old_emails_sent_count + 1)
          end
        end
      end
    end
  end
end
