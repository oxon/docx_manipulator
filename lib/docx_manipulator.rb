require 'docx_manipulator/version'
require 'docx_manipulator/content'
require 'docx_manipulator/relationships'

require 'zip/zip'

class DocxManipulator

  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target

    @content = Content.new
    @relationships = Relationships.new(source)
  end

  def content(new_content, options = {})
    @content.set(new_content, options)
  end

  def add_image(id, path)
    @relationships.add_image(id, path)
  end

  def add_binary_image(id, name, data)
    @relationships.add_binary_image(id, name, data)
  end

  def process
    files_to_be_written = @content.writes_to_files + @relationships.writes_to_files

    Zip::ZipOutputStream.open(target) do |os|
      Zip::ZipFile.foreach(source) do |entry|
        unless files_to_be_written.include?(entry.name)
          os.put_next_entry entry.name
          os.write entry.get_input_stream.read
        end
      end

      @content.process(os)
      @relationships.process(os)
    end
  end

end
