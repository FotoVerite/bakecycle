require 'digest/sha2'

class LegacyImporterMailer < ActionMailer::Base
  default from: 'admin@bakecycle.com'

  def invalid_clients_csv(csv)
    attachments["invalid_clients_#{Date.today.to_default_s}.csv"] = { mime_type: 'text/csv', content: csv }
    mail to: 'admin@bakecycle.com'
  end
end
