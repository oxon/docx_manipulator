RSpec::Matchers.define :be_like_docx do |expected|
  match do |actual|
    Zip::ZipFile.open(expected) do |output_file|
      Zip::ZipFile.open(actual) do |sample_file|
          output_file.read('word/document.xml').gsub(/\s+/, '') == sample_file.read('word/document.xml').gsub(/\s+/, '')
      end
    end
  end
end
