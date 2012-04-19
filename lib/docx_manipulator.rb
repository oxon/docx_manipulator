require 'docx_manipulator/version'
require 'nokogiri'
require 'zip/zip'
require 'i18n'

require 'docx_manipulator/content'
require 'docx_manipulator/images'

class DocxManipulator

  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target
    @binary_images = {}

    @content = Content.new
    @images = Images.new(source_relationships)
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
    @content.set(new_content, options)
  end

  def add_image(id, path)
    @images.add(id, path)
  end

  def add_binary_image(id, name, data)
    @images.add_binary(id, I18n.transliterate(name), data)
  end

  def process
    Zip::ZipOutputStream.open(target) do |os|
      Zip::ZipFile.foreach(source) do |entry|
        os.put_next_entry entry.name
        if entry.name == 'word/document.xml'
          os.write @content.new_content
        elsif entry.name == 'word/_rels/document.xml.rels'
          os.write @images.relationships.to_s
        elsif entry.file?
          os.write entry.get_input_stream.read
        end
      end

      @images.images.each do |id, path|
        os.put_next_entry "word/media/#{I18n.transliterate(File.basename(path))}"
        File.open(path) do |file|
          IO.copy_stream file, os
        end
      end

      @images.binary_images.each do |name, data|
        os.put_next_entry "word/media/#{I18n.transliterate(name)}"
        os.write data
      end
    end
  end

end
