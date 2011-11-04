require 'docx_creator'

describe DocxCreator do

  subject { DocxCreator }

  describe ".translate" do
    let!(:manipulator) { DocxCreator::DocxManipulator.new('a', 'b') }

    before :each do
      subject.stub(:transform_data) { 'transformed data' }
      DocxCreator::DocxManipulator.stub(:new) { manipulator }
      DocxCreator::DocxManipulator.any_instance.stub(:process)
    end

    it "saves the new content" do
      manipulator.should_receive(:content=).with('transformed data')
      subject.translate('a', 'b', 'c', 'd')
    end

    it "processes the result" do
      manipulator.should_receive(:process)
      subject.translate('a', 'b', 'c', 'd')
    end
  end

  describe ".transform_data" do
    it "transforms the data according to the XSLT file" do
      output = subject.send(:transform_data, 'spec/files/document.xslt', 'spec/files/data.xml')
      output.should =~ /The Departed/
      output.should =~ /The Pursuit of Happyness/
    end
  end

end
