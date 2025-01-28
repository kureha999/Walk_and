require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'アソシエーション' do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

  describe 'バリデーション' do
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:body).is_at_most(50) }
  end
end
