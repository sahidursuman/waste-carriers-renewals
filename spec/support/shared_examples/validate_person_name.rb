# Tests for fields using the PersonNameValidator
RSpec.shared_examples "validate person name" do |form_factory, field|
  context "when a valid transient registration exists" do
    let(:form) { build(form_factory, :has_required_data) }

    context "when a name meets the requirements" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when a name is blank" do
      before(:each) do
        form.send("#{field}=", "")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a name is too long" do
      before(:each) do
        form.send("#{field}=", "0fJQLDxvB77dz3SbcMDSH60kM82VUUMOlpZBkIUnh1IIUE0zF4r3NbHotPIzlbeQdCWB1qa")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end

    context "when a name contains invalid characters" do
      before(:each) do
        form.send("#{field}=", "W@ste")
      end

      it "is not valid" do
        expect(form).to_not be_valid
      end
    end
  end
end
