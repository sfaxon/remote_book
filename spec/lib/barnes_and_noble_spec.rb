require 'spec_helper'

describe RemoteBook::BarnesAndNoble do
  before(:each) do
    RemoteBook::BarnesAndNoble.associate_keys = {:web_service_token => 'doesnt matter for test'}
  end

end
