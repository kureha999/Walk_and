require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:image) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:liked_users).through(:likes).source(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body).on(:create) }
    it { should validate_length_of(:body).is_at_most(200) }
  end

  describe '#image_content_type' do
    let(:valid_image_path) { Rails.root.join('spec/fixtures/test_image.jpg') }

    it 'allows valid image types' do
      post = build(:post, image: fixture_file_upload(valid_image_path, 'image/jpeg'))
      expect(post).to be_valid
    end

    it 'does not allow invalid image types' do
      Tempfile.create([ 'invalid_file', '.txt' ]) do |tempfile|
        tempfile.write('Invalid content')
        tempfile.rewind

        post = build(:post)
        post.image.attach(
          io: File.open(tempfile.path),
          filename: 'invalid_file.txt',
          content_type: 'text/plain' # 無効な MIME タイプを指定
        )

        post.valid?

        expect(post.errors[:image]).to include("対応していないファイル形式です。JPEG, PNG, GIF, HEICのみアップロード可能です。")
      end
    end
  end
end
