class InvoiceItemsController < ApplicationController
  def update
    invoice_item = InvoiceItem.find(params[:id])
    merchant = invoice_item.merchant
    invoice = invoice_item.invoice

    invoice_item.update(status: params[:status])

    redirect_to merchant_invoice_path(merchant, invoice)
  end
end
