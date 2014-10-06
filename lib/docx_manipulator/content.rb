require 'nokogiri'

class DocxManipulator::Manipulator
  class Content
    attr_reader :writes_to_file

    def initialize(path, new_content, options = {})
      @writes_to_file = path
      @new_content = if new_content.kind_of?(File)
                       new_content.read
                     else
                       new_content
                     end
      if options.include?(:xslt)
        xslt = Nokogiri::XSLT.parse(options[:xslt])
        data = Nokogiri::XML.parse(@new_content)
        @new_content = xslt.transform(data).to_s
      end
    end

    def process(output)
      output.put_next_entry @writes_to_file
      output.write @new_content
    end
  end
end
