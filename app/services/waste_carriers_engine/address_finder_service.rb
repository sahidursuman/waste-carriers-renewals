require "rest-client"

module WasteCarriersEngine
  class AddressFinderService
    def initialize(postcode)
      # Strip out non-alphanumeric characters
      @postcode = postcode.gsub(/[^a-z0-9]/i, "")
      @url = Rails.configuration.os_places_service_url + "/addresses?postcode=" + @postcode
    end

    def search_by_postcode
      Rails.logger.debug "Sending request to OS Places service"

      begin
        response = RestClient::Request.execute(
          method: :get,
          url: @url
        )

        begin
          JSON.parse(response)
        rescue JSON::ParserError => e
          Airbrake.notify(e) if defined?(Airbrake)
          Rails.logger.error "OS Places JSON error: " + e.to_s
          :error
        end
      rescue RestClient::BadRequest
        Rails.logger.debug "OS Places: resource not found"
        :not_found
      rescue RestClient::ExceptionWithResponse => e
        Airbrake.notify(e) if defined?(Airbrake)
        Rails.logger.error "OS Places response error: " + e.to_s
        :error
      rescue SocketError => e
        Airbrake.notify(e) if defined?(Airbrake)
        Rails.logger.error "OS Places socket error: " + e.to_s
        :error
      end
    end
  end
end
