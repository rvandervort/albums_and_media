class FileExtensionValidator < ActiveModel::Validator
  def validate(record)
    fields.each do |field|
      attr_value = record.send(field)
      if file_extensions.none? { |extension| !attr_value.blank? && attr_value.match("#{extension}$") }
        record.errors.add field.to_s, "Invalid file extension. requires : #{file_extensions.join(", ")}"
      end
    end
  end

  private

  def fields
    Array(options[:fields])
  end

  def file_extensions
    options[:extensions]
  end
end
