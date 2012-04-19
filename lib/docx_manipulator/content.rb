require 'nokogiri'

class DocxManipulator
  class Content
    def set(new_content, options = {})
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

    def writes_to_files
      ['word/document.xml']
    end

    def process(output)
      output.put_next_entry 'word/document.xml'
      output.write @new_content
    end
  end
end
