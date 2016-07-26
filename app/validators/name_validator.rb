class NameValidator < ActiveModel::Validator
  def validate(record)
    if record.name.blank?
      record.errors.add :name, "Name cannot be blank"
    end
  end
end
