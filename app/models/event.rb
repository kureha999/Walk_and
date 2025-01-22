class Event < ApplicationRecord
  belongs_to :user

  enum event_type: { walk: 0, food: 1 }

  validates :title, presence: true
  validates :time, presence: true
end
