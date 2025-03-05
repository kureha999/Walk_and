require "aws-sdk-s3"
require "cloudinary"
require "open-uri"

class CloudinaryWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.debug "Cloudinary webhook received!"
    Rails.logger.debug "Request body: #{request.body.read}"

    payload = request.body.read
    event = JSON.parse(payload)
    secure_url = event["secure_url"]
    public_id = event["public_id"]
    format = event["format"]
    asset_id = event["asset_id"]

    begin

      image_data = URI.open(secure_url).read


      s3 = Aws::S3::Resource.new(
        region: "ap-northeast-1",
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
      )

      object_key = "#{public_id}.#{format}"
      obj = s3.bucket("walk-and").object(object_key)
      obj.put(body: image_data, content_type: "image/#{format}")


      Cloudinary::Uploader.destroy(public_id)


      post = Post.find_by(cloudinary_asset_id: asset_id)
      if post

        presigned_url = obj.presigned_url(:get, expires_in: 3600)
        post.update(image: presigned_url)
      end

    rescue => e
      Rails.logger.error "Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.message }, status: :internal_server_error
      return
    end

    head :ok
  rescue JSON::ParserError => e
    render json: { error: "Invalid JSON" }, status: :bad_request
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
