RSpec::Matchers.define :contain_docx_text do |text|
  match do |actual|
    Zip::ZipFile.open(actual) do |sample_file|
      sample_file.read('word/document.xml').include? text.to_s.encode(:xml => :text)
    end
  end
end
