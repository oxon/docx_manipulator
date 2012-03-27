require 'docx_manipulator/version'
require 'nokogiri'
require 'zip/zip'

class DocxManipulator

  attr_reader :source, :target, :new_content, :new_relationships

  def initialize(source, target)
    @source = source
    @target = target
    @new_relationships = source_relationships
    @images = {}
  end

  def source_content
    content = ''
    Zip::ZipFile.open(source) do |file|
      content = file.read('word/document.xml')
    end
    content
  end

  def source_relationships
    content = ''
    Zip::ZipFile.open(source) do |file|
      content = file.read('word/_rels/document.xml.rels')
    end
    Nokogiri::XML.parse(content)
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

  def add_image(id, path)
    @images[id] = path
    image_node = Nokogiri::XML::Node.new('Relationship', new_relationships)
    image_node['Id'] = id
    image_node['Type'] = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'
    image_node['Target'] = "media/#{File.basename(path)}"
    new_relationships.root << image_node
  end

  def process
    Zip::ZipOutputStream.open(target) do |os|
      Zip::ZipFile.foreach(source) do |entry|
        os.put_next_entry entry.name
        if entry.name == 'word/document.xml'
          os.write @new_content
        elsif entry.name == 'word/_rels/document.xml.rels'
          os.write new_relationships.to_s
        elsif entry.file?
          os.write entry.get_input_stream.read
        end
      end

      @images.each do |id, path|
        os.put_next_entry "word/media/#{File.basename(path)}"
        File.open(path) do |file|
          IO.copy_stream file, os
        end
      end
    end
  end

end
