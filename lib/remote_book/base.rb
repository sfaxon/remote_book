module RemoteBook
  class Base
    attr_accessor :large_image, :medium_image, :small_image, :link, :authors, :title, :isbn, :digital_link
    
    def author
      @authors.join(", ")
    end

    class << self
      def associate_keys
        @@associate_keys ||= {}
      end
      
      def associate_keys=(obj)
        @@associate_keys = obj
      end

      def setup
        yield self
      end
      
      def find_by_isbn(isbn)
        self.find(:isbn => isbn)
      end

      def find(options)

      end
    end
  end
end
