require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
module GemCov
  describe GemHash  do
    it "should respond to .update!" do
      subject.should respond_to :update! 
    end
    it "should respond to .all_gems" do
      subject.should respond_to :all_gems 
    end
    it "should respond to .common_gems" do
      subject.should respond_to :common_gems
    end
    it "should respond to .desired_gems" do
      subject.should respond_to :desired_gems
    end
    it "should respond to .default_gems" do
      subject.should respond_to :default_gems
    end
  end
end
