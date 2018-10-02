module WasteCarriersEngine
  class WorldpayFormsController < FormsController
    def new
      super(WorldpayForm, "worldpay_form")

      payment_info = prepare_for_payment
      if payment_info == :error
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.new.setup_error")
        go_back
      else
        redirect_to payment_info[:url]
      end
    end

    def create; end

    def success
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      order = find_order_by_code(params[:orderKey])

      if new_worldpay_service(params, order).valid_success?
        log_worldpay_response(true, "success")
        @transient_registration.next!
        redirect_to_correct_form
      else
        log_worldpay_response(false, "success")
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.success.invalid_response")
        go_back
      end
    end

    def failure
      respond_to_unsuccessful_payment(:failure)
    end

    def cancel
      respond_to_unsuccessful_payment(:cancel)
    end

    def error
      respond_to_unsuccessful_payment(:error)
    end

    def pending
      respond_to_unsuccessful_payment(:pending)
    end

    private

    def prepare_for_payment
      FinanceDetails.new_finance_details(@transient_registration, :worldpay, current_user)
      order = @transient_registration.finance_details.orders.first
      worldpay_service = WorldpayService.new(@transient_registration, order, current_user)
      worldpay_service.prepare_for_payment
    end

    def respond_to_unsuccessful_payment(action)
      return unless set_up_valid_transient_registration?(params[:reg_identifier])

      if unsuccessful_response_is_valid?(action, params)
        log_worldpay_response(true, action)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.#{action}.message")
      else
        log_worldpay_response(false, action)
        flash[:error] = I18n.t(".waste_carriers_engine.worldpay_forms.#{action}.invalid_response")
      end

      go_back
    end

    def set_up_valid_transient_registration?(reg_identifier)
      set_transient_registration(reg_identifier)
      setup_checks_pass?
    end

    def find_order_by_code(full_order_key)
      order_code = get_order_key(full_order_key)
      order = @transient_registration.finance_details.orders.where(order_code: order_code).first
      return order if order.present?

      Rails.logger.error "Invalid WorldPay response: could not find matching order"
      nil
    end

    def get_order_key(order_key)
      return nil unless order_key.present?
      order_key.match(/[0-9]{10}$/).to_s
    end

    def unsuccessful_response_is_valid?(action, params)
      order = find_order_by_code(params[:orderKey])
      valid_method = "valid_#{action}?".to_sym

      new_worldpay_service(params, order).public_send(valid_method)
    end

    def new_worldpay_service(params, order)
      WorldpayService.new(@transient_registration, order, current_user, params)
    end

    def log_worldpay_response(is_valid, action)
      valid_text = if is_valid
                     "Valid"
                   else
                     "Invalid"
                   end

      Rails.logger.debug "#{valid_text} WorldPay response for #{params[:reg_identifier]}: #{action}"
      Rails.logger.debug "Params:"
      Rails.logger.debug params.to_json
    end
  end
end
