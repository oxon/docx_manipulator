RSpec::Matchers.define :contain_docx_file do |file|
  match do |actual|
    content = file.read
    Zip::File.open(actual) do |sample_file|
      contains = []
      Zip::File.foreach(actual) do |f|
        contains << (sample_file.read(f) == content)
      end
      contains.any?
    end
  end
end
