require "rails_helper"

module WasteCarriersEngine
  RSpec.describe GeneratePdfService do
    context "testing" do
      it "has the right config" do
        expect(WickedPdf.config[:exe_path]).to eq("#{Dir.pwd}/script/wkhtmltopdf.sh")
      end
      it "can generate a pdf" do
        pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')
        expect(pdf).not_to eq(nil)
      end
    end
  end
end
