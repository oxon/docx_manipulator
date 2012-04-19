require 'i18n'
require 'nokogiri'

class DocxManipulator
  class Relationships
    def initialize(source)
      @relationships = read_relationships(source)
      @images = []
      @binary_images = {}
    end

    def read_relationships(path)
      content = ''
      Zip::ZipFile.open(path) do |file|
        content = file.read('word/_rels/document.xml.rels')
      end
      Nokogiri::XML.parse(content)
    end
    private :read_relationships

    def add_image(id, path)
      @images << path
      add_node(id, I18n.transliterate(File.basename(path)))
    end

    def add_binary_image(id, name, data)
      name = I18n.transliterate(name)
      @binary_images[name] = data
      add_node(id, name)
    end

    def add_node(id, name)
      image_node = Nokogiri::XML::Node.new('Relationship', @relationships)
      image_node['Id'] = id
      image_node['Type'] = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'
      image_node['Target'] = "media/#{name}"
      @relationships.root << image_node
    end
    private :add_node

    def writes_to_files
      ['word/_rels/document.xml.rels']
    end

    def process(output)
      output.put_next_entry 'word/_rels/document.xml.rels'
      output.write @relationships.to_s

      @images.each do |path|
        output.put_next_entry "word/media/#{I18n.transliterate(File.basename(path))}"
        File.open(path) do |file|
          IO.copy_stream file, output
        end
      end

      @binary_images.each do |name, data|
        output.put_next_entry "word/media/#{I18n.transliterate(name)}"
        output.write data
      end
    end
  end
end
