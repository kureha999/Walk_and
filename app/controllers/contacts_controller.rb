class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      ContactMailer.contact_email(@contact).deliver_now
      flash[:notice] = t("contact.controller.notice")
      redirect_to new_contact_path
    else
      flash.now[:alert] = t("contact.controller.alert")
      render :new
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
