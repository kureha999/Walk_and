class Event < ApplicationRecord
  belongs_to :user

  enum event_type: { お散歩: 0, お食事: 1 }

  validates :title, presence: true
  validates :time, presence: true
end
