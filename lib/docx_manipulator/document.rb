module DocxManipulator
  class Document
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def data
      Zip::File.open(file) do |zip|
          zip.read('word/document.xml')
      end
    end

    def include?(object)
      self.data.include?(object)
    end

  end
end
