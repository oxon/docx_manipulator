RSpec::Matchers.define :be_like_docx do |expected|
  match do |actual|
    Zip::File.open(expected) do |output_file|
      Zip::File.open(actual) do |sample_file|
          output_file.read('word/document.xml').gsub(/\s+/, '') == sample_file.read('word/document.xml').gsub(/\s+/, '')
      end
    end
  end
end
