# -*- coding: utf-8 -*-
require 'docx_manipulator/templater'
describe DocxManipulator::Templater do
  let(:input_docx_path) {'spec/files/notes.docx'}
  let(:xml) do
    builder = Builder::XmlMarkup.new
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.note do
      builder.to "Tove"
      builder.from "Jani"
      builder.heading "Reminder"
      builder.body "Don't forget me this weekend!"
    end
  end

  it "should accept a file or a file path" do
    templater1 = described_class.new input_docx_path, xml
    file = File.new(input_docx_path)
    templater2 = described_class.new file, xml
    templater1.generate_xslt.should == templater2.generate_xslt
    templater1.generate_xslt.should_not be_nil
    file.close
  end

  context "with a given docx file" do
    subject { described_class.new input_docx_path, xml }

    its(:placeholders) { should =~ ['/note/from', '/note/to', '/note/heading', '/note/body'] }

    it "#generate_xslt and #generate_xslt! should return the same value if all placeholder were satisfied" do
      subject.generate_xslt == subject.generate_xslt!
    end

    it "should replace the given placeholder with xslt value-of commands" do
      output = subject.generate_xslt
      subject.placeholders.each do |p|
        output.should include("<xsl:value-of select=\"#{p}\" />")
      end
    end

    context "in case of more xml leaves than placeholders" do
      let(:xml) do
        builder = Builder::XmlMarkup.new
        builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        builder.note do
          builder.to "Check!"
          builder.from "Check!"
          builder.heading "Check!"
          builder.body "Check!"
          builder.something "Wooops!"
        end
      end

      it "should check if all xml leaves were used" do
        expect { subject.generate_xslt! }.to raise_exception
      end
    end

    it "should output a valid xslt template" do
      Nokogiri::XSLT.parse(subject.generate_xslt!)
    end

    context "with only one xml leaf" do
      let(:xml) do
        builder = Builder::XmlMarkup.new
        builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        builder.note do
          builder.from "Unknown"
        end
      end

      its(:placeholders) { should =~ ['/note/from'] }
    end

    context "in action" do
      let (:created_xslt_path) { File.join('spec', 'files', 'output', 'created.xslt')}
      let (:output_path) { File.join('spec', 'files', 'output', 'output.docx') }

      before :each do
        FileUtils.mkdir_p File.dirname output_path
      end

      after :each do
        FileUtils.rm_rf "#{File.dirname output_path}/.", :secure => true
      end

      it "it should transform the given docx" do
        File.open(created_xslt_path, 'w') do |f|
          f.write subject.generate_xslt
        end
        manipulator = DocxManipulator::Manipulator.new input_docx_path, output_path
        manipulator.content xml, :xslt => File.new(created_xslt_path)
        manipulator.process
      end
    end
  end

end
