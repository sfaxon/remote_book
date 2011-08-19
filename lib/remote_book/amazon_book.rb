class AmazonBook < RemoteBook
  # mac os 10.5 does not ship with SHA256 support built into ruby, 10.6 does. 
  DIGEST_SUPPORT = OpenSSL::Digest.constants.include?('SHA256') || OpenSSL::Digest.constants.include?(:SHA256)
  DIGEST = OpenSSL::Digest::Digest.new('sha256') if DIGEST_SUPPORT
  
  def initialize
    # @@amazon_config_path = Rails.root.join('config', 'amazon.yml')
    # @@amazon_config = YAML.load_file(@@amazon_config_path)[Rails.env].symbolize_keys

    @@associates_id = @@amazon_config[:associates_id]
    @@key_id        = @@amazon_config[:key_id]
    @@secret_key    = @@amazon_config[:secret_key]
  end
  
  
private 
  def build_isbn_lookup_query(item_id)
    base = "http://ecs.amazonaws.com/onca/xml" 
    query = "Service=AWSECommerceService&"
    query << "AWSAccessKeyId=#{@@key_id}&"
    query << "AssociateTag=#{@@associates_id}&"
    query << "Operation=ItemLookup&"
    query << "ItemId=#{item_id}&"
    query << "ResponseGroup=ItemAttributes,Offers,Images&"
    # query << "ResponseGroup=ItemAttributes&"
    query << "Version=2009-07-01"
    sig_query = sign_query base, query, @@secret_key
    base + "?" + sig_query
  end
  # most of this is from http://www.justinball.com/2009/09/02/amazon-ruby-and-signing_authenticating-your-requests/ 
  #  which is actually from the ruby-aaws gem 
  def sign_query(uri, query, amazon_secret_access_key = "", locale = :us)
    uri = URI.parse(uri)
    # only add current timestamp if it's not in the query, a timestamp passed in via query takes precedence 
    # I'm only doing this so the checksum comes out correctly with the example from the amazon documentation
    query << "&Timestamp=#{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}" unless query.include?("Timestamp")
    new_query = query.split('&').collect{|param| "#{param.split('=')[0]}=#{url_encode(param.split('=')[1])}"}.sort.join('&')
    # puts new_query
    to_sign = "GET\n%s\n%s\n%s" % [uri.host, uri.path, new_query]
    # step 7 of http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html
    hmac = OpenSSL::HMAC.digest(DIGEST, amazon_secret_access_key, to_sign)
    base64_hmac = [hmac].pack('m').chomp
    signature = url_encode(base64_hmac)

    new_query << "&Signature=#{signature}"

  end

  # Shamelessly plagiarised from Wakou Aoyama's cgi.rb, but then altered slightly to please AWS.
  def url_encode(string)
    string.gsub( /([^a-zA-Z0-9_.~-]+)/ ) do
      '%' + $1.unpack( 'H2' * $1.bytesize ).join( '%' ).upcase
    end
  end
end