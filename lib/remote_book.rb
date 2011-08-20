require "rubygems"
require "uri"
require "openssl"
require "typhoeus"
require "nokogiri"

require "remote_book/base"
require "remote_book/amazon"

module RemoteBook
  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp
end
