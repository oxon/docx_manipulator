require 'zip/zip'

module DocxCreator
  class DocxManipulator

    attr_reader :source, :target

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

    def content=(new_content)
      @content = new_content
    end

    def process
      Zip::ZipOutputStream.open(target) do |os|
        Zip::ZipFile.foreach(source) do |entry|
          os.put_next_entry entry.name
          if entry.name == 'word/document.xml'
            os.write @content
          else
            os.write entry.get_input_stream.read
          end
        end
      end
    end

  end
end
