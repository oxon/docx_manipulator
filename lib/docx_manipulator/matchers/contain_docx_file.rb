RSpec::Matchers.define :contain_docx_file do |file|
  match do |actual|
    content = file.read
    Zip::ZipFile.open(actual) do |sample_file|
      Zip::ZipFile.foreach(actual).any? { |f| sample_file.read(f) == content }
    end
  end
end
