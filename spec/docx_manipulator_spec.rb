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
    let(:xml_string) { <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<Movies>
  <Genre name="Drama">
    <Movie>
      <Name>The Departed</Name>
      <Released>2006</Released>
    </Movie>
    <Movie>
      <Name>The Pursuit of Happyness</Name>
      <Released>2006</Released>
    </Movie>
  </Genre>
</Movies>
EOF
    }

    it "transforms the data file with an xslt file" do
      subject.content File.new('spec/files/data.xml'), :xslt => File.new('spec/files/document.xslt')
      subject.new_content.should =~ /<w:t>The Departed<\/w:t>/
      subject.new_content.should =~ /<w:t>The Pursuit of Happyness<\/w:t>/
    end

    it "transforms a string with an xslt file" do
      subject.content xml_string, :xslt => File.new('spec/files/document.xslt')
      subject.new_content.should =~ /<w:t>The Departed<\/w:t>/
      subject.new_content.should =~ /<w:t>The Pursuit of Happyness<\/w:t>/
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

  describe '#add_image' do
    it 'adds an image to the relations file' do
      subject.add_image 'rId9', 'path/to/image.jpg'
      subject.new_relationships.to_s.should =~ /<Relationship Id="rId9" Type="http:\/\/schemas.openxmlformats.org\/officeDocument\/2006\/relationships\/image" Target="media\/image.jpg"\/>/
    end
  end

  describe '#add_binary_image' do
    let(:image) { File.new(File.join(File.dirname(__FILE__), 'files', 'duck.jpeg'), 'rb') }
    it 'adds an image in binary format to the docx' do
      data = image.read
      subject.add_binary_image 'rId18', 'duck.jpeg', data
      subject.new_relationships.to_s.should =~ /<Relationship Id="rId18" Type="http:\/\/schemas.openxmlformats.org\/officeDocument\/2006\/relationships\/image" Target="media\/duck.jpeg"\/>/
      subject.process

      Zip::ZipFile.open('spec/files/result.docx') do |file|
        file.read('word/media/duck.jpeg').should == data
      end
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

    context 'with an image' do
      it 'replaces the relations file' do
        subject.add_image 'rId19', 'spec/files/duck.jpeg'
        subject.process
        Zip::ZipFile.open('spec/files/result.docx') do |file|
          content = Nokogiri::XML.parse(file.get_input_stream('word/_rels/document.xml.rels').read)
          content.xpath('//r:Relationship[@Id="rId19"]', 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships').first['Target'].should == 'media/duck.jpeg'
        end
      end

      it 'adds the image to the resulting file' do
        subject.add_image 'rId19', 'spec/files/duck.jpeg'
        subject.process
        Zip::ZipFile.open('spec/files/result.docx') do |file|
          file.find_entry('word/media/duck.jpeg').should_not be_nil
        end
      end
    end
  end

end
