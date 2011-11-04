require 'docx_creator/docx_manipulator'
require 'docx_creator/version'
require 'nokogiri'

module DocxCreator

  class << self
    def translate(template, xslt, data, result_file)
      f = DocxManipulator.new(template, result_file)
      f.content = transform_data(xslt, data)
      f.process
    end

    def transform_data(xslt_file, data_file)
      xslt = Nokogiri::XSLT.parse(File.open(xslt_file))
      data = Nokogiri::XML.parse(File.open(data_file))
      xslt.transform(data).to_s
    end
    private :transform_data
  end

end
