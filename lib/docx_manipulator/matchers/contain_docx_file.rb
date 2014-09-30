RSpec::Matchers.define :contain_docx_file do |file|
  match do |actual|
    content = file.read
    Zip::File.open(actual) do |sample_file|
      Zip::File.foreach(actual).any? { |f| sample_file.read(f) == content }
    end
  end
end
