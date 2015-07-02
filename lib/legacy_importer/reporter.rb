module LegacyImporter
  class Reporter
    attr_reader :objects

    def initialize(objects)
      @objects = objects.map { |o| Decorator.new(o) }
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << ['Type', 'Name', 'Legacy ID', 'Errors']
        invalid_report.each { |row| csv << row }
      end
    end

    def send_email
      LegacyImporterMailer.invalid_clients_csv(csv).deliver_now
    end

    def imported_count
      @objects.count(&:persisted?)
    end

    def invalid_count
      invalid_objects.count
    end

    def skipped_report
      counts = skipped_objects.each_with_object(Hash.new(0)) do |obj, memo|
        memo[obj.type_name] += 1
      end
      counts.map { |klass, count|
        "Skipped #{count} #{klass}"
      }.join("\n")
    end

    def skipped_objects
      @objects.select(&:skipped?)
    end

    def skipped_count
      skipped_objects.count
    end

    class Decorator
      attr_reader :object
      def initialize(object)
        @object = object
      end

      def method_missing(method, *args, &block)
        object.send(method, *args, &block)
      end

      def skipped?
        object.is_a? SkippedObject
      end

      def to_s
        return object.name if object.respond_to? :name
        return "#{object.class}:#{id}" if object.try(:id)
        object.to_s
      end

      def type_name
        object.class.to_s
      end

      def legacy_identifier
        return object.legacy_id if object.respond_to? :legacy_id
        ''
      end

      def errors?
        return false if skipped?
        object.errors.any?
      end
    end

    private

    def invalid_objects
      @objects.select(&:errors?)
        .sort_by(&:to_s)
        .sort_by(&:type_name)
    end

    def invalid_report
      invalid_objects.map do |object|
        errors = object.errors.full_messages.join('|')
        [object.type_name, object.to_s, object.legacy_identifier, errors]
      end
    end
  end
end
