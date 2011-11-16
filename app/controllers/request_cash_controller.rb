class RequestCashController < ApplicationController
  def create
    order = current_user.request_cashs.build(:credit => params['credit'])
    if current_user.credit >= order.credit and order.save
      current_user.update_attributes(:credit => current_user.credit - order.credit,:locked_credit => current_user.locked_credit + order.credit)
      redirect_to accounts_url
    else
    end
  end

end
