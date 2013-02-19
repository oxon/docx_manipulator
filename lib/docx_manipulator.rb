require 'docx_manipulator/version'
require 'docx_manipulator/content'
require 'docx_manipulator/relationships'

require 'zip/zip'

class DocxManipulator

  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target

    @changed_files = []
    @relationships = Relationships.new(source)
  end

  def content(new_content, options = {})
    @changed_files << Content.new('word/document.xml', new_content, options)
  end

  def add_file(path, data, options = {})
    @changed_files << Content.new(path, data, options)
  end

  def add_image(id, path)
    @relationships.add_image(id, path)
  end

  def add_relationship(id, type, target, attributes = {})
    @relationships.add_node(id, type, target, attributes)
  end

  def add_binary_image(id, name, data)
    @relationships.add_binary_image(id, name, data)
  end

  def process
    files_to_be_written = @changed_files.map(&:writes_to_file).flatten + @relationships.writes_to_files

    Zip::ZipOutputStream.open(target) do |os|
      Zip::ZipFile.foreach(source) do |entry|
        if !files_to_be_written.include?(entry.name) && entry.file?
          os.put_next_entry entry.name
          os.write entry.get_input_stream.read
        end
      end

      @changed_files.each {|f| f.process(os)}
      @relationships.process(os)
    end
  end

end
