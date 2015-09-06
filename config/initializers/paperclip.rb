Paperclip.options[:content_type_mappings] = {
  iif: "text/plain"
}

if ENV["AWS_S3_KEY"]
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
      bucket: ENV["AWS_S3_BUCKET"],
      access_key_id: ENV["AWS_S3_ID"],
      secret_access_key: ENV["AWS_S3_KEY"]
    }
  Paperclip::Attachment.default_options[:s3_protocol] = :https
end
