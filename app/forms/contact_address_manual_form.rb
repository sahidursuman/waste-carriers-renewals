class ContactAddressManualForm < ManualAddressForm
  private

  def saved_temp_postcode
    @transient_registration.temp_contact_postcode
  end

  def existing_address
    @transient_registration.contact_address
  end

  def address_type
    "CONTACT"
  end
end