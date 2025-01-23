class Contact < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 200 }
end
