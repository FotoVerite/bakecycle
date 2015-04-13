module LegacyImporter
  class Reporter
    attr_reader :objects

    def initialize(objects)
      @objects = objects
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << ['Type', 'Name', 'Legacy ID', 'Invalid Attributes']
        invalid_report.each { |row| csv << row }
      end
    end

    def send_email
      LegacyImporterMailer.invalid_clients_csv(csv).deliver_now
    end

    def imported_count
      @objects.select(&:persisted?).count
    end

    def invalid_count
      invalid_objects.count
    end

    def skipped_count
      @objects.select { |o|
        !o.persisted? && o.valid?
      }.count
    end

    private

    def invalid_objects
      @objects.select { |o| !o.valid? }
        .sort_by(&:name)
        .sort_by { |o| o.class.to_s }
    end

    def invalid_report
      invalid_objects.map do |client|
        invalid_keys = client.errors.messages.keys
        invalid_attributes = invalid_keys.map { |key| "#{key}:#{client[key]}" }.join('|')
        [client.class, client.name, client.legacy_id, invalid_attributes]
      end
    end
  end
end
