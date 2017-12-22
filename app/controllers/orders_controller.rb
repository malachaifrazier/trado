class OrdersController < ApplicationController
  skip_before_action :authenticate_user!
  include CartBuilder

  def confirm
    set_order
    set_address_variables
    validate_confirm_render
  end

  def complete
    set_order
    if @order.completed?
      return render_order_already_completed
    end

    redirect_url = Store::PayProvider.new(order: @order, provider: @order.payment_type, session: session, ip_address: request.remote_ip).complete
    redirect_to redirect_url
  end

  def success
    set_session_order
    if @order.latest_transaction.pending? || @order.latest_transaction.completed?
      render theme_presenter.page_template_path('orders/success'), layout: theme_presenter.layout_template_path
    else
      redirect_to root_url
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url
  end

  def failed
    set_session_order
    if @order.latest_transaction.failed?
      render theme_presenter.page_template_path('orders/failed'), layout: theme_presenter.layout_template_path
    else
      redirect_to root_url
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_url
  end

  def retry
    set_order
    if Modulatron4000.paypal? && TradoPaypalModule::Paypaler.fatal_error_code?(@order.last_error_code)
      Payatron4000.decommission_order(@order)
    end
    redirect_to mycart_carts_url
  end

  def destroy
    set_order
    Payatron4000.decommission_order(@order)
    flash_message :success, t('controllers.orders.destroy.valid')
    redirect_to root_url
  end

  private

  def set_session_order
    @order = Order.active.includes(:delivery_address).find(session[:order_id])
  end

  def set_order
    @order ||= Order.active.find(params[:id])
  end

  def set_eager_loading_order
    @order ||= Order.active.includes(:delivery_address, :billing_address).find(params[:id])
  end

  def set_address_variables
    @delivery_address = @order.delivery_address
    @billing_address  = @order.billing_address
  end

  def validate_confirm_render
    if Payatron4000.order_pay_provider_valid?(@order, params)
      TradoPaypalModule::Paypaler.assign_paypal_token(params[:token], params[:PayerID], @order) if @order.paypal?
      render theme_presenter.page_template_path('orders/confirm'), layout: theme_presenter.layout_template_path
    else
      flash_message :error, t('controllers.orders.validate_confirm_render.invalid')
      redirect_to checkout_carts_url
    end
  end

  def render_order_already_completed
    redirect_to success_orders_url, notice: 'Your order has already been completed'
  end
end