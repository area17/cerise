require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "cherry task" do
  context "without indicating a ticket" do
    it 'should fail about not supplied ticket argument' do
      lambda { run_task }.should raise_error(RuntimeError, /You must supply at least one ticket number/)
    end

    it 'should fail about improper ticket format' do
      lambda { run_task('') }.should raise_error(RuntimeError, /You must supply at least one ticket number/)
    end
  end

  private
  def run_task(arg = nil)
    Rake::Task['cherry'].reenable
    Rake::Task['cherry'].invoke(arg)
  end
end
