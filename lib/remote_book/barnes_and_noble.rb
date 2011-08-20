module RemoteBook
  class BarnesAndNoble < RemoteBook::Base
    ISBN_SEARCH_BASE_URI = "http://search.barnesandnoble.com/booksearch/isbnInquiry.asp?ISBSRC=Y&ISBN="
    LINK_SHARE_DEEP_LINK_BASE = "http://getdeeplink.linksynergy.com/createcustomlink.shtml"
    BN_LINK_SHARE_MID = "36889"
    
    def self.find(options)
      b = new
      if options[:isbn]
        bn_page = barnes_and_noble_page_link_for(options[:isbn])
        return nil unless bn_page

        b.link = link_share_deep_link_for(bn_page)
      end
      b
    end
  
  private
    def self.build_isbn_lookup_query(isbn)
      ISBN_SEARCH_BASE_URI + isbn
    end
    # pass the ISBN to the search service, read the redirect information, and use that as store link
    def self.barnes_and_noble_page_link_for(isbn)
      search_path = build_isbn_lookup_query(isbn)
      response = RemoteBook.get_url(search_path, :read_timeout => 6, :open_timeout => 4)
      if response.respond_to?(:each_header)
        response.each_header do |name, value|
          return value if "location" == name
        end
      end
      false
    end
    # based on a pdf linked at the bottom of this page: http://helpcenter.linkshare.com/publisher/questions.php?questionid=61
    # direct pdf link (working 20 aug 2011): 
    # http://helpcenter.linkshare.com/publisher/getattachment.php?data=NjF8QXV0b21hdGVkIExpbmtHZW5lcmF0b3IgMi4xLS1NYXkgMjAxMS5wZGY%3D
    def self.link_share_deep_link_for(url)
      token = associate_keys[:web_service_token]
      deep_link_lookup = LINK_SHARE_DEEP_LINK_BASE + "?token=" + token + "&mid=" + BN_LINK_SHARE_MID + "&murl=" + url
      a = RemoteBook.get_url(deep_link_lookup, :read_timeout => 6, :open_timeout => 4)
      if a.response.respond_to?(:code) && "200" == a.response.code
        return a.response.body
      end
      return nil
    end
  end
end