class ContactMailer < ApplicationMailer
  default to: "maple09100908@gmail.com"

  def contact_email(contact)
    @contact = contact
    mail(subject: t("contact.mailer.subject"))
  end
end
