require 'docx_manipulator/version'
require 'nokogiri'
require 'zip/zip'

class DocxManipulator

  attr_reader :source, :target, :new_content

  def initialize(source, target)
    @source = source
    @target = target
  end

  def source_content
    content = ''
    Zip::ZipFile.open(source) do |file|
      content = file.read('word/document.xml')
    end
    content
  end

  def content(new_content, options = {})
    new_content_string = case new_content
                         when File then new_content.read
                         else new_content
                         end
    if options.include?(:xslt)
      xslt = Nokogiri::XSLT.parse(options[:xslt])
      data = Nokogiri::XML.parse(new_content_string)
      @new_content = xslt.transform(data).to_s
    else
      @new_content = new_content_string
    end
  end

  def process
    Zip::ZipOutputStream.open(target) do |os|
      Zip::ZipFile.foreach(source) do |entry|
        os.put_next_entry entry.name
        if entry.name == 'word/document.xml'
          os.write @new_content
        else
          os.write entry.get_input_stream.read
        end
      end
    end
  end

end
