class DocxManipulator
  class Images
    attr_reader :relationships, :images, :binary_images

    def initialize(relationships)
      @relationships = relationships
      @images = {}
      @binary_images = {}
    end

    def add(id, path)
      @images[id] = path

      image_node = Nokogiri::XML::Node.new('Relationship', @relationships)
      image_node['Id'] = id
      image_node['Type'] = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'
      image_node['Target'] = "media/#{I18n.transliterate(File.basename(path))}"
      @relationships.root << image_node
    end

    def add_binary(id, name, data)
      @binary_images[name] = data
      image_node = Nokogiri::XML::Node.new('Relationship', @relationships)
      image_node['Id'] = id
      image_node['Type'] = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'
      image_node['Target'] = "media/#{name}"
      @relationships.root << image_node
    end
  end
end
