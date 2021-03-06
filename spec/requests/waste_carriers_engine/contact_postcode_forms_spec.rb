require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ContactPostcodeForms", type: :request do
    include_examples "GET flexible form", form = "contact_postcode_form"

    describe "POST contact_postcode_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "contact_postcode_form")
          end

          context "when valid params are submitted" do
            let(:valid_params) {
              {
                reg_identifier: transient_registration[:reg_identifier],
                temp_contact_postcode: "BS1 6AH"
              }
            }

            before do
              example_json = { postcode: "BS1 6AH" }
              allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(example_json)
            end

            it "returns a 302 response" do
              post contact_postcode_forms_path, contact_postcode_form: valid_params
              expect(response).to have_http_status(302)
            end

            it "updates the transient registration" do
              post contact_postcode_forms_path, contact_postcode_form: valid_params
              expect(transient_registration.reload[:temp_contact_postcode]).to eq(valid_params[:temp_contact_postcode])
            end

            it "redirects to the contact_address form" do
              post contact_postcode_forms_path, contact_postcode_form: valid_params
              expect(response).to redirect_to(new_contact_address_form_path(transient_registration[:reg_identifier]))
            end

            context "when a postcode search returns an error" do
              before(:each) do
                allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(:error)
              end

              it "redirects to the contact_address_manual form" do
                post contact_postcode_forms_path, contact_postcode_form: valid_params
                expect(response).to redirect_to(new_contact_address_manual_form_path(transient_registration[:reg_identifier]))
              end
            end
          end

          context "when invalid params are submitted" do
            let(:invalid_params) {
              {
                reg_identifier: "foo",
                temp_contact_postcode: "ABC123DEF456"
              }
            }

            it "returns a 302 response" do
              post contact_postcode_forms_path, contact_postcode_form: invalid_params
              expect(response).to have_http_status(302)
            end

            it "does not update the transient registration" do
              post contact_postcode_forms_path, contact_postcode_form: invalid_params
              expect(transient_registration.reload[:temp_contact_postcode]).to_not eq(invalid_params[:temp_contact_postcode])
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              temp_contact_postcode: "BS1 5AH"
            }
          }

          it "returns a 302 response" do
            post contact_postcode_forms_path, contact_postcode_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post contact_postcode_forms_path, contact_postcode_form: valid_params
            expect(transient_registration.reload[:temp_contact_postcode]).to_not eq(valid_params[:temp_contact_postcode])
          end

          it "redirects to the correct form for the state" do
            post contact_postcode_forms_path, contact_postcode_form: valid_params
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end

    describe "GET back_contact_postcode_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "contact_postcode_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the contact_email form" do
              get back_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_contact_email_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response" do
              get back_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get back_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end

    describe "GET skip_to_manual_address_contact_postcode_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "contact_postcode_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the contact_address_manual form" do
              get skip_to_manual_address_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_contact_address_manual_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:transient_registration,
                   :has_required_data,
                   :has_postcode,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the skip_to_manual_address action is triggered" do
            it "returns a 302 response" do
              get skip_to_manual_address_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to have_http_status(302)
            end

            it "redirects to the correct form for the state" do
              get skip_to_manual_address_contact_postcode_forms_path(transient_registration[:reg_identifier])
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
            end
          end
        end
      end
    end
  end
end
