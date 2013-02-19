# -*- coding: utf-8 -*-
require 'docx_manipulator'
require 'zip/zip'

describe DocxManipulator do

  subject { DocxManipulator.new('spec/files/movies.docx', 'spec/files/result.docx') }

  after :each do
    File.delete('spec/files/result.docx') if File.exist?('spec/files/result.docx')
  end

  it "generates the resulting document" do
    subject.process
    File.should exist('spec/files/result.docx')
  end

  context 'content' do
    it "accepts a string" do
      subject.content 'bla'
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        file.get_input_stream('word/document.xml').read.should == 'bla'
      end
    end

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
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        data = file.get_input_stream('word/document.xml').read
        data.should =~ /<w:t>The Departed<\/w:t>/
        data.should =~ /<w:t>The Pursuit of Happyness<\/w:t>/
      end
    end

    it "transforms a string with an xslt file" do
      subject.content xml_string, :xslt => File.new('spec/files/document.xslt')
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        data = file.get_input_stream('word/document.xml').read
        data.should =~ /<w:t>The Departed<\/w:t>/
        data.should =~ /<w:t>The Pursuit of Happyness<\/w:t>/
      end
    end

    it "accepts a string" do
      subject.content 'the new content'
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        data = file.get_input_stream('word/document.xml').read
        data.should == 'the new content'
      end
    end

    it "accepts a file as input" do
      subject.content File.new('spec/files/content.txt')
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        data = file.get_input_stream('word/document.xml').read
        data.should == 'this is the new content of the document'
      end
    end
  end

  context 'add a custom file' do
    let(:data) { '<translations><page>Seite</page></translations>' }
    it 'transforms the data file with an xslt template' do
      subject.add_file 'word/footer.xml', data, :xslt => File.new('spec/files/footer.xslt')
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        data = file.get_input_stream('word/footer.xml').read
        data.should =~ /<w:t xml:space="preserve">Seite<\/w:t>/
      end
    end
  end

  context 'with an image' do
    it 'adds an image' do
      subject.add_image 'rId19', 'spec/files/duck.jpeg'
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        content = Nokogiri::XML.parse(file.get_input_stream('word/_rels/document.xml.rels').read)
        content.xpath('//r:Relationship[@Id="rId19"]', 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships').first['Target'].should == 'media/duck.jpeg'
        file.find_entry('word/media/duck.jpeg').should_not be_nil
      end
    end

    it 'adds an image as binary data' do
      file = File.new(File.join(File.dirname(__FILE__), 'files', 'duck.jpeg'), 'rb')
      data = file.read
      subject.add_binary_image 'rId19', 'duck.jpeg', data
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        content = Nokogiri::XML.parse(file.get_input_stream('word/_rels/document.xml.rels').read)
        content.xpath('//r:Relationship[@Id="rId19"]', 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships').first['Target'].should == 'media/duck.jpeg'
        file.read('word/media/duck.jpeg').should == data
      end
    end

    it 'transliterates the image name' do
      file = File.new(File.join(File.dirname(__FILE__), 'files', 'duck.jpeg'), 'rb')
      data = file.read
      subject.add_binary_image 'rId19', 'dück.jpeg', data
      subject.process
      Zip::ZipFile.open('spec/files/result.docx') do |file|
        content = Nokogiri::XML.parse(file.get_input_stream('word/_rels/document.xml.rels').read)
        content.xpath('//r:Relationship[@Id="rId19"]', 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships').first['Target'].should == 'media/duck.jpeg'
        file.find_entry('word/media/duck.jpeg').should_not be_nil
      end
    end
  end

  context 'relationsships' do
    it 'adds a reletionshop' do
      subject.add_relationship('rId28', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink', 'http://www.fricktalischer-reiterclub.ch', 'TargetMode' => 'External')
      subject.process

      Zip::ZipFile.open('spec/files/result.docx') do |file|
        content = Nokogiri::XML.parse(file.get_input_stream('word/_rels/document.xml.rels').read)
        node = content.xpath('//r:Relationship[@Id="rId28"]', 'r' => 'http://schemas.openxmlformats.org/package/2006/relationships').first
        node['Target'].should == 'http://www.fricktalischer-reiterclub.ch'
        node['TargetMode'].should == 'External'
      end
    end
  end

end
