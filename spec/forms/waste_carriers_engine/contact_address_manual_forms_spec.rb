require "rails_helper"

module WasteCarriersEngine
  RSpec.describe ContactAddressManualForm, type: :model do
    describe "#initialize" do
      context "when the transient registration has an address already" do
        let(:transient_registration) do
          build(:transient_registration,
                :has_addresses,
                workflow_state: "contact_address_manual_form")
        end
        # Don't use FactoryBot for this as we need to make sure it initializes with a specific object
        let(:contact_address_manual_form) { ContactAddressManualForm.new(transient_registration) }

        context "when the business type is overseas" do
          before(:each) do
            transient_registration.business_type = "overseas"
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(transient_registration.registered_address.house_number)
          end
        end

        context "when the temp_contact_postcode doesn't exist" do
          before(:each) do
            transient_registration.temp_contact_postcode = nil
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(transient_registration.registered_address.house_number)
          end
        end

        context "when the temp_contact_postcode matches the existing address" do
          before(:each) do
            transient_registration.temp_contact_postcode = transient_registration.registered_address.postcode
          end

          it "prefills the form with the existing address" do
            expect(contact_address_manual_form.house_number).to eq(transient_registration.registered_address.house_number)
          end
        end

        context "when the temp_contact_postcode is in use and doesn't match the registered address" do
          before(:each) do
            transient_registration.temp_contact_postcode = "foo"
          end

          it "prefills the form with the temp_contact_postcode" do
            expect(contact_address_manual_form.postcode).to eq(transient_registration.temp_contact_postcode)
          end

          it "does not prefill the form with the existing address" do
            expect(contact_address_manual_form.address_line_1).to_not eq(transient_registration.registered_address.address_line_1)
          end
        end
      end
    end

    describe "#submit" do
      context "when the form is valid" do
        let(:contact_address_manual_form) { build(:contact_address_manual_form, :has_required_data) }
        let(:valid_params) do
          {
            reg_identifier: contact_address_manual_form.reg_identifier,
            house_number: contact_address_manual_form.house_number,
            address_line_1: contact_address_manual_form.address_line_1,
            address_line_2: contact_address_manual_form.address_line_2,
            town_city: contact_address_manual_form.town_city,
            postcode: contact_address_manual_form.postcode,
            country: contact_address_manual_form.country
          }
        end

        it "should submit" do
          expect(contact_address_manual_form.submit(valid_params)).to eq(true)
        end
      end

      context "when the form is not valid" do
        let(:contact_address_manual_form) { build(:contact_address_manual_form, :has_required_data) }
        let(:invalid_params) { { reg_identifier: "foo" } }

        it "should not submit" do
          expect(contact_address_manual_form.submit(invalid_params)).to eq(false)
        end
      end
    end

    context "when a valid transient registration exists" do
      let(:contact_address_manual_form) { build(:contact_address_manual_form, :has_required_data) }

      context "when everything meets the requirements" do
        it "is valid" do
          expect(contact_address_manual_form).to be_valid
        end
      end

      describe "#house_number" do
        context "when the house_number is blank" do
          before(:each) do
            contact_address_manual_form.house_number = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end

        context "when the house_number is too long" do
          before(:each) do
            contact_address_manual_form.house_number = "1767217672701701770041563533191862858216711534112759290091467119071305962652874388673510958015949702771617744287044629700938926040595129731732659267801150029749795917354487895716341751221579349683254601"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end

      describe "#address_line_1" do
        context "when the address_line_1 is blank" do
          before(:each) do
            contact_address_manual_form.address_line_1 = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end

        context "when the address_line_1 is too long" do
          before(:each) do
            contact_address_manual_form.address_line_1 = "dj2mpm1gioexmhxsomk9o7oo8h5c7y7o8j2pmnwxefvoy91v9ghm7saz10r2lmdqhl3r6of58qlmlar2qeepah8c9rs8i78s2j94ws6y0gq1mxy4cw6s5myjugw62er6d2gpai0b11gsb18s2sfb9rcllye22b38o4"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end

      describe "#address_line_2" do
        context "when the address_line_2 is too long" do
          before(:each) do
            contact_address_manual_form.address_line_2 = "gsm2lgu3q7cg5pcs02ftc1wtpx4lt5ghmyaclhe9qg9li7ibs5ldi3w3n1pt24pbfo0666bq"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end

      describe "#town_city" do
        context "when the town_city is blank" do
          before(:each) do
            contact_address_manual_form.town_city = nil
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end

        context "when the town_city is too long" do
          before(:each) do
            contact_address_manual_form.town_city = "4jhjdq46425oqers8r0b0xejkl19bapc"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end

      describe "#postcode" do
        context "when the postcode is too long" do
          before(:each) do
            contact_address_manual_form.postcode = "4jhjdq46425oqers8r0b0xejkl19bapc"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end

      describe "#country" do
        context "when the country is blank" do
          before(:each) do
            contact_address_manual_form.country = nil
          end

          context "when the business_type is not overseas" do
            before(:each) do
              contact_address_manual_form.business_type = "limitedContact"
            end

            it "is valid" do
              expect(contact_address_manual_form).to be_valid
            end
          end

          context "when the business_type is overseas" do
            before(:each) do
              contact_address_manual_form.business_type = "overseas"
            end

            it "is not valid" do
              expect(contact_address_manual_form).to_not be_valid
            end
          end
        end

        context "when the country is too long" do
          before(:each) do
            contact_address_manual_form.country = "f8x4jhjdq46425oqers8r0b0xejkl19bapc4jhjdq46425oqers"
          end

          it "is not valid" do
            expect(contact_address_manual_form).to_not be_valid
          end
        end
      end
    end
  end
end
