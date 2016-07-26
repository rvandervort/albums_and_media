require 'database_cleaner'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  # Only clean the database if necessary
  # Otherwise the tests get much slower
  config.around(:each) do |example|
    if example.metadata[:db]
      DatabaseCleaner.cleaning do
        example.run
      end
    else
      example.run
    end
  end
end
