# frozen_string_literal: true

Paperclip.options[:content_type_mappings] = {
  iif: "text/plain"
}

aws_s3_bucket = ENV["AWS_S3_BUCKET"].presence || Rails.application.credentials.dig(:aws, :bucket)
aws_s3_id = ENV["AWS_S3_ID"].presence || Rails.application.credentials.dig(:aws, :access_key_id)
aws_s3_key = ENV["AWS_S3_KEY"].presence || Rails.application.credentials.dig(:aws, :secret_access_key)

if aws_s3_bucket.present? && aws_s3_id.present? && aws_s3_key.present?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
      bucket: aws_s3_bucket,
      access_key_id: aws_s3_id,
      secret_access_key: aws_s3_key
    }
  Paperclip::Attachment.default_options[:s3_protocol] = :https
end
