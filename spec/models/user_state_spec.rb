require 'rails_helper'

RSpec.describe UserState, type: :model do
  describe 'アソシエーション' do
    it { should belong_to(:user) }
  end

  describe 'バリデーション' do
    it { should validate_presence_of(:state) }
  end
end
