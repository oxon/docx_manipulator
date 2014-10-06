# -*- coding: utf-8 -*-
require 'docx_manipulator'
require 'docx_manipulator/matchers'
require 'builder'

describe DocxManipulator do


  let(:input_path) {'spec/files/movies.docx'}
  let(:output_path) {'spec/files/result.docx'}


  before :each do
    manipulator = DocxManipulator::Manipulator.new(input_path, output_path)
    manipulator.content xml, :xslt => File.new('spec/files/document.xslt')
    manipulator.process
  end

  after :each do
    subject.close
    File.delete('spec/files/result.docx') if File.exist?('spec/files/result.docx')
  end

  subject { File.new output_path }


  let(:xml) do
    builder = Builder::XmlMarkup.new
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.Movies do
      builder.Genre do
        builder.Movie do
          builder.Name "Keinohrhasen"
        end
        builder.Movie do
          builder.Name "Kokowääh"
        end
      end
    end
  end

  it "should check if the specified string is in the document" do
    subject.should contain_docx_text "Keinohrhasen"
  end
  it "should consider xml encoding" do
    subject.should contain_docx_text "Kokowääh"
  end

end
