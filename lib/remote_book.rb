require "rubygems"
require "uri"
require "net/http"
require "openssl"
require "nokogiri"

require "remote_book/base"
require "remote_book/amazon"
require "remote_book/barnes_and_noble"

module RemoteBook
  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp

  def self.get_url(url, options = {:read_timeout => 2, :open_timeout => 2})
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = options[:read_timeout]
    http.open_timeout = options[:open_timeout]
    # this return structure is pretty ugly
    begin
      res = http.start { |web|
        g = Net::HTTP::Get.new(uri.request_uri)
        web.request(g)
      }
    rescue Timeout::Error
      return {:body => "error: timeout", :status => :error}
    rescue Exception => e
      return {:body => "error: #{e}", :status => :error}
    else
      return res
    end
  end
end
