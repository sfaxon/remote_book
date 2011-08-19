class RemoteBook
  attr_accessor :large_image, :medium_image, :small_image, :link, :author, :title, :isbn, :digital_link
  
  class << self
    def find_by_isbn(isbn)
      self.find(:isbn => isbn)
    end
  
    def find(options)
    
    end
  end
end