require 'spec_helper'

describe RemoteBook::BarnesAndNoble do
  before(:each) do
    RemoteBook::BarnesAndNoble.associate_keys = {:web_service_token => 'doesntmatterfortest'}
  end
  it "should set link on successful get" do
    affiliate_link = "http://click.linksynergy.com/fs-bin/some_ugly_path"
    raw_link = "http://search.barnesandnoble.com/bookpath/"
    FakeWeb.register_uri(:get, RemoteBook::BarnesAndNoble::ISBN_SEARCH_BASE_URI+"1433506254",
                               :body => "redirect",
                               :location => raw_link)
    FakeWeb.register_uri(:get, %r|http://getdeeplink\.linksynergy\.com/(.*)|, :body => affiliate_link)
    a = RemoteBook::BarnesAndNoble.find_by_isbn("1433506254")
    a.link.should == affiliate_link
    a.affiliate_link.should == affiliate_link
    a.raw_link.should == raw_link
  end
  
  it "should set link to raw link when affiliate lookup fails" do
    affiliate_link = "http://click.linksynergy.com/fs-bin/some_ugly_path"
    raw_link = "http://search.barnesandnoble.com/bookpath/"
    FakeWeb.register_uri(:get, RemoteBook::BarnesAndNoble::ISBN_SEARCH_BASE_URI+"1433506254",
                               :body => "redirect",
                               :location => raw_link)
    FakeWeb.register_uri(:get, %r|http://getdeeplink\.linksynergy\.com/(.*)|, :body => "err", :status => ["404", "Not Found"])
    a = RemoteBook::BarnesAndNoble.find_by_isbn("1433506254")
    a.link.should == raw_link
    a.affiliate_link.should be_nil
    a.raw_link.should == raw_link
  end
end
