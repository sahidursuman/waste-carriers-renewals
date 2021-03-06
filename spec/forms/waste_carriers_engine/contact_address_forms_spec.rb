require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressForm, type: :model do
    # Stub the address search so we have JSON to use
    before do
      address_json = build(:contact_address_form, :has_required_data).temp_addresses
      allow_any_instance_of(AddressFinderService).to receive(:search_by_postcode).and_return(address_json)
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:contact_address_form) { build(:contact_address_form, :has_required_data) }
        let(:valid_params) { { reg_identifier: contact_address_form.reg_identifier, temp_address: contact_address_form.temp_address } }

        it "should submit" do
          VCR.use_cassette("contact_postcode_form_valid_postcode") do
            expect(contact_address_form.submit(valid_params)).to eq(true)
          end
        end
      end

      context "when the form is not valid" do
        let(:contact_address_form) { build(:contact_address_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          VCR.use_cassette("contact_postcode_form_valid_postcode") do
            expect(contact_address_form.submit(invalid_params)).to eq(false)
          end
        end
      end
    end

    context "when a form with a valid transient registration exists" do
      let(:contact_address_form) { build(:contact_address_form, :has_required_data) }

      describe "#addresses" do
        context "when no address is selected" do
          before(:each) do
            contact_address_form.addresses = nil
          end

          it "is not valid" do
            expect(contact_address_form).to_not be_valid
          end
        end
      end
    end

    context "when a form with a valid transient registration exists and the transient registration already has an address" do
      let(:transient_registration) do
        build(:transient_registration,
              :has_postcode,
              :has_addresses,
              workflow_state: "contact_address_form")
      end
      # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
      let(:contact_address_form) { ContactAddressForm.new(transient_registration) }

      describe "#temp_address" do
        it "pre-selects the address" do
          expect(contact_address_form.temp_address).to eq(transient_registration.contact_address.uprn.to_s)
        end
      end
    end
  end
end
