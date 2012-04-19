class DocxManipulator
  class Content
    attr_reader :new_content

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
  end
end
