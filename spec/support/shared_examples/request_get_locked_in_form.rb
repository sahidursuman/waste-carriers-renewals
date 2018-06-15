# A 'locked-in' form is a form we definitely don't want users to access out-of-order,
# for example, by clicking the back button or URL-hacking.
# Users shouldn't be able to get into locked-in forms this way.
# They also shouldn't be able to get out of them, except by using buttons within the app.
# This prevents users from skipping past the payment stage, or trying to go back and
# make changes to their information after they've completed a renewal.
RSpec.shared_examples "GET locked-in form" do |form|
  context "when a valid user is signed in" do
    let(:user) { create(:user) }
    before(:each) do
      sign_in(user)
    end

    context "when no renewal is in progress" do
      let(:registration) do
        create(:registration,
               :has_required_data,
               :expires_soon,
               account_email: user.email)
      end

      it "redirects to the renewal_start_form" do
        get new_path_for(form, registration)
        expect(response).to redirect_to(new_renewal_start_form_path(registration[:reg_identifier]))
      end
    end

    context "when a renewal is in progress" do
      let(:transient_registration) do
        create(:transient_registration,
               :has_required_data,
               account_email: user.email)
      end

      context "when the workflow_state matches the requested form" do
        before do
          transient_registration.update_attributes(workflow_state: form)
        end

        it "loads the form" do
          get new_path_for(form, transient_registration)
          expect(response).to have_http_status(200)
        end

        it "does not change the workflow_state" do
          state_before_request = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(state_before_request)
        end
      end

      context "when the workflow_state is a flexible form" do
        before do
          transient_registration.update_attributes(workflow_state: "other_businesses_form")
        end

        it "redirects to the saved workflow_state" do
          workflow_state = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
        end

        it "does not change the workflow_state" do
          state_before_request = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(state_before_request)
        end
      end

      context "when the workflow_state is a locked-in form" do
        before do
          # We need to pick a different but also valid state for the transient_registration
          # 'payment_summary_form' is the default, unless this would actually match!
          different_state = if form == "payment_summary_form"
                              "cards_form"
                            else
                              "payment_summary_form"
                            end
          transient_registration.update_attributes(workflow_state: different_state)
        end

        it "redirects to the saved workflow_state" do
          workflow_state = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(response).to redirect_to(new_path_for(workflow_state, transient_registration))
        end

        it "does not change the workflow_state" do
          state_before_request = transient_registration[:workflow_state]
          get new_path_for(form, transient_registration)
          expect(transient_registration.reload[:workflow_state]).to eq(state_before_request)
        end
      end
    end
  end

  # Should call a method like new_location_form_path("CBDU1234")
  def new_path_for(form, transient_registration)
    reg_id = transient_registration[:reg_identifier] if transient_registration.present?
    send("new_#{form}_path", reg_id)
  end
end