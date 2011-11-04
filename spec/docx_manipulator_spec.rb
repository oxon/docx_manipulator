require 'docx_manipulator'
require 'zip/zip'

describe DocxManipulator do

  subject { DocxManipulator.new('spec/files/movies.docx', 'spec/files/result.docx') }

  describe "#source_content" do
    it "returns the content of document.xml" do
      subject.source_content.should =~ /w:document/
    end
  end

  describe "#content" do
    it "transforms the data file with an xslt file" do
      subject.content File.new('spec/files/data.xml'), :xslt => File.new('spec/files/document.xslt')
      subject.new_content.should =~ /The Departed/
      subject.new_content.should =~ /The Pursuit of Happyness/
    end

    it "accepts a string" do
      subject.content 'the new content'
      subject.new_content.should == 'the new content'
    end

    it "accepts a file as input" do
      subject.content File.new('spec/files/content.txt')
      subject.new_content.should == 'this is the new content of the document'
    end
  end

  describe "#process" do
    after :each do
      File.delete 'spec/files/result.docx'
    end

    it "generates the resulting document" do
      subject.process
      File.should exist('spec/files/result.docx')
    end

    it "replaces the content of the document" do
      subject.content 'bla'
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        file.get_input_stream('word/document.xml').read.should == 'bla'
      end
    end
  end

end
