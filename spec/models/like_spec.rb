require 'rails_helper'

RSpec.describe Like, type: :model do
  subject { create(:like) }
  describe 'アソシエーション' do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  describe 'バリデーション' do
    it { should validate_uniqueness_of(:user_id).scoped_to(:post_id) }
  end
end
