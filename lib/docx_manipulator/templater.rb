require 'nokogiri'
require 'docx_manipulator'
module DocxManipulator
  class Templater
    XSLT_START = <<-EOS
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    EOS
    XSLT_END= <<-EOS
  </xsl:template>
  </xsl:stylesheet>
    EOS


    attr_reader :docx_path, :xml

    def initialize(docx, xml)
      if docx.respond_to? :path
        @docx_path = docx
      else
        @docx_path = Pathname.new(docx)
      end

      @xml = Nokogiri::XML::parse(xml)
    end

    def generate_xslt(destination=nil)
      try_to_write(bare_xslt[0], destination)
    end

    def generate_xslt!(destination=nil)
      bare, errors = bare_xslt
      unless errors.empty?
        message = "Not all placeholders were satisfied!"
        message = errors.inject(message) {| message, e| message << "\n" << e}
        raise message
      end
      try_to_write(bare, destination)
    end

    def placeholders
      leaves
    end

    private

    def try_to_write(result, destination)
      if destination.respond_to? :write
        destination.write result
      elsif destination.respond_to?(:file?)
        File.new(destination, 'w').write(result)
      end
      result
    end

    def leaves(node = xml.root)
      node.xpath('.//*[not(*)]').map(&:path)
    end

    def bare_xslt
      document = DocxManipulator::Document.new(docx_path)
      xslt = document.data
      missed = []
      placeholders.each do |placeholder|
        hit = xslt.gsub!(/#{Regexp.escape(placeholder)}/, "<xsl:value-of select=\"#{placeholder}\" />")
        unless hit
          missed << placeholder
        end
      end
      xslt = XSLT_START << xslt << XSLT_END
      return xslt, missed
    end


  end
end
