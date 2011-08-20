require 'spec_helper'

describe RemoteBook::BarnesAndNoble do
  before(:each) do
    RemoteBook::BarnesAndNoble.associate_keys = {:web_service_token => 'doesntmatterfortest'}
  end
  it "should set link on successful get" do
    dest = "http://click.linksynergy.com/fs-bin/some_ugly_path"
    FakeWeb.register_uri(:get, RemoteBook::BarnesAndNoble::ISBN_SEARCH_BASE_URI+"1433506254",
                               :body => "redirect",
                               :location => "http://search.barnesandnoble.com/bookpath/")
    FakeWeb.register_uri(:get, %r|http://getdeeplink\.linksynergy\.com/(.*)|, :body => dest)
    a = RemoteBook::BarnesAndNoble.find_by_isbn("1433506254")
    a.link.should == dest
  end
end
