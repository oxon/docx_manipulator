# -*- coding: utf-8 -*-
require 'docx_manipulator'
describe DocxManipulator::Document do
  let(:input_path) {'spec/files/movies.docx'}
  subject { described_class.new input_path }

  it "should return the main data of the docx" do
    subject.data.should =~ /Movies/
  end

  it "should contain the main data (text) of the docx" do
    subject.should include "Movies"
  end

end
