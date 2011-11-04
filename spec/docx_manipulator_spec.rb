require 'docx_manipulator'
require 'zip/zip'

describe DocxManipulator do

  subject { DocxManipulator.new('spec/files/movies.docx', 'spec/files/result.docx') }

  describe ".source_content" do
    it "returns the content of document.xml" do
      subject.source_content.should =~ /w:document/
    end
  end

  describe ".process" do
    after :each do
      File.delete 'spec/files/result.docx'
    end

    it "generates the resulting document" do
      subject.process
      File.should exist('spec/files/result.docx')
    end

    it "replaces the content of the document" do
      subject.content = 'bla'
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        file.get_input_stream('word/document.xml').read.should == 'bla'
      end
    end
  end

end
