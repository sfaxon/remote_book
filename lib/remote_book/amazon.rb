module RemoteBook
  class Amazon < RemoteBook::Base
    attr_accessor :large_image, :medium_image, :small_image, :authors, :title, :isbn, :digital_link
    
    # FIXME: failed digest support should raise exception.
    # mac os 10.5 does not ship with SHA256 support built into ruby, 10.6 does. 
    DIGEST_SUPPORT = ::OpenSSL::Digest.constants.include?('SHA256') || ::OpenSSL::Digest.constants.include?(:SHA256)
    DIGEST = ::OpenSSL::Digest::Digest.new('sha256') if DIGEST_SUPPORT
    
    def self.find(options)
      a = new
      # unless DIGEST_SUPPORT raise "no digest sup"
      if options[:isbn]
        req = build_isbn_lookup_query(options[:isbn])
        response = RemoteBook.get_url(req)

        if response.respond_to?(:code) && "200" == response.code
          xml_doc = Nokogiri.XML(response.body)
        else 
          return false 
        end

        if 1 == xml_doc.xpath("//xmlns:Items").size
          if xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:LargeImage/xmlns:URL")
            a.large_image  = xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:LargeImage/xmlns:URL").inner_text
          end
          if xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:MediumImage/xmlns:URL")
            a.medium_image = xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:MediumImage/xmlns:URL").inner_text
          end
          if xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:SmallImage/xmlns:URL")
            a.small_image  = xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:SmallImage/xmlns:URL")
          end
          a.title        = xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:ItemAttributes/xmlns:Title").inner_text
          a.authors = []
          xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:ItemAttributes/xmlns:Author").each do |author|
            a.authors << author.inner_text
          end
          # ewww
          if xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:ItemLinks/xmlns:ItemLink/xmlns:Description='Technical Details'")
            xml_doc.xpath("//xmlns:Items/xmlns:Item/xmlns:ItemLinks/xmlns:ItemLink").each do |item_link|
              if "Technical Details" == item_link.xpath("xmlns:Description").inner_text
                a.link = item_link.xpath("xmlns:URL").inner_text
              end
            end
          end
        end
      end  
      return a
    end
  
  private 
    def self.build_isbn_lookup_query(item_id)
      base = "http://ecs.amazonaws.com/onca/xml" 
      query = "Service=AWSECommerceService&"
      query << "AWSAccessKeyId=#{associate_keys[:key_id]}&"
      query << "AssociateTag=#{associate_keys[:associates_id]}&"
      query << "Operation=ItemLookup&"
      query << "ItemId=#{item_id}&"
      query << "ResponseGroup=ItemAttributes,Offers,Images&"
      # query << "ResponseGroup=ItemAttributes&"
      query << "Version=2009-07-01"
      sig_query = sign_query base, query, associate_keys[:secret_key]
      base + "?" + sig_query
    end
    # most of this is from http://www.justinball.com/2009/09/02/amazon-ruby-and-signing_authenticating-your-requests/ 
    #  which is actually from the ruby-aaws gem 
    def self.sign_query(uri, query, amazon_secret_access_key = "", locale = :us)
      uri = URI.parse(uri)
      # only add current timestamp if it's not in the query, a timestamp passed in via query takes precedence 
      # I'm only doing this so the checksum comes out correctly with the example from the amazon documentation
      query << "&Timestamp=#{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}" unless query.include?("Timestamp")
      new_query = query.split('&').collect{|param| "#{param.split('=')[0]}=#{url_encode(param.split('=')[1])}"}.sort.join('&')
      to_sign = "GET\n%s\n%s\n%s" % [uri.host, uri.path, new_query]
      # step 7 of http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html
      hmac = OpenSSL::HMAC.digest(DIGEST, amazon_secret_access_key, to_sign)
      base64_hmac = [hmac].pack('m').chomp
      signature = url_encode(base64_hmac)

      new_query << "&Signature=#{signature}"
    end

    # Shamelessly plagiarised from Wakou Aoyama's cgi.rb, but then altered slightly to please AWS.
    def self.url_encode(str)
      str.gsub( /([^a-zA-Z0-9_.~-]+)/ ) do
        '%' + $1.unpack( 'H2' * $1.bytesize ).join( '%' ).upcase
      end
    end
  end
end