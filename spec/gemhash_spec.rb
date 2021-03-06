require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
module GemCov
  describe GemHash  do
    methods_to_check = [:update!, :all_gems, :common_gems, :desired_gems, :default_gems]
    methods_to_check.each do |method_to_check|
      it "should respond to #{method_to_check}" do
        subject.should respond_to method_to_check
      end
    end
  end
end
