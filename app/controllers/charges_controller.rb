class ChargesController < ApplicationController
  helper_method :updateStatus

  def new
    @order_items = current_order.order_items
    @GST = current_order.subtotal * current_customer.province.GST
    @PST = current_order.subtotal * current_customer.province.PST
    @total = @GST + @PST + current_order.subtotal

    @description = 'Details of Charge'
  end

  def create
    @order_items = current_order.order_items
    @GST = current_order.subtotal * current_customer.province.GST
    @PST = current_order.subtotal * current_customer.province.PST
    @total = @GST + @PST + current_order.subtotal

    @customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :source  => params[:stripeToken]
    )

    @charge = Stripe::Charge.create(    :customer    => @customer.id,
                                        :amount      => (@total*100).to_i,
                                        :description => 'Double Fancy Customer',
                                        :currency    => 'usd')

    def updateStatus
      @order = current_order
      @order.update_columns(order_status_id: 3);
      @order.save
    end

  rescue Stripe::CardError => e
    flash[:error] = e,message
    redirect_to charges_new_path
  end
end
