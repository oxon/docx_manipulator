RSpec::Matchers.define :be_a_docx do
  match do |actual|
    File.extname(actual.path) == ".docx"
  end
end
