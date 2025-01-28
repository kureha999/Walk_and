require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'アソシエーション' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_one(:user_state).dependent(:destroy) }
  end

  describe 'deviseモジュールに関するテスト' do
    it 'Deviseモジュールを含むべきである' do
      expect(User.ancestors).to include(Devise::Models::DatabaseAuthenticatable)
      expect(User.ancestors).to include(Devise::Models::Omniauthable)
    end
  end
end
