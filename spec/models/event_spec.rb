require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:time) }
  end

  describe 'enums' do
    it { should define_enum_for(:event_type).with_values(walk: 0, food: 1) }
  end
end
