# frozen_string_literal: true

Paperclip.options[:content_type_mappings] = {
  iif: "text/plain"
}

aws_s3_bucket = ENV["AWS_S3_BUCKET"].presence || Rails.application.credentials.dig(:aws, :bucket)
aws_s3_id = ENV["AWS_S3_ID"].presence || ENV["AWS_ACCESS_KEY_ID"].presence ||
            Rails.application.credentials.dig(:aws, :access_key_id)
aws_s3_key = ENV["AWS_S3_KEY"].presence || ENV["AWS_SECRET_ACCESS_KEY"].presence ||
             Rails.application.credentials.dig(:aws, :secret_access_key)
aws_s3_region = ENV["AWS_S3_REGION"].presence || ENV["AWS_REGION"].presence ||
                Rails.application.credentials.dig(:aws, :region).presence || "us-east-1"

if aws_s3_bucket.present? && aws_s3_id.present? && aws_s3_key.present?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
      bucket: aws_s3_bucket,
      access_key_id: aws_s3_id,
      secret_access_key: aws_s3_key,
      s3_region: aws_s3_region
    }
  Paperclip::Attachment.default_options[:s3_region] = aws_s3_region
  Paperclip::Attachment.default_options[:s3_protocol] = :https
  Paperclip::Attachment.default_options[:s3_acl_enabled] = false
end
