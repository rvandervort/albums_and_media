class PositionValidator < ActiveModel::Validator
  def validate(record)
    if record.position.nil? || record.position < 0
      record.errors.add :position, "position must be a positive integer"
    end
  end
end
