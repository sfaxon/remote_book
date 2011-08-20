# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

require 'fakeweb'

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  FakeWeb.allow_net_connect = false

  config.before(:each) do
    FakeWeb.clean_registry
  end
end

def load_file(name)
  file = File.open("spec/fixtures/#{name}", "rb")
  contents = file.read
  file.close
  return contents
end
