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

  context 'with a supplied ticket' do
    before :each do
      @helper = mock(GitHelper, :null_object => true)
      @helper.stub!(:find_by_tickets).and_return(mocked_commits)

      GitHelper.stub!(:new).and_return(@helper)
    end

    it 'should find the relevant commits from master' do
      out, _ = run_task('426')
      out.should match(/Applying commit f665dcd/)
    end

    it 'should apply relevant commits in order' do
      @helper.should_receive(:apply_commit).once.ordered.with("f665dcd").and_return(true)
      @helper.should_receive(:apply_commit).once.ordered.with("8a65b36").and_return(true)
      @helper.should_receive(:apply_commit).once.ordered.with("cea9613").and_return(true)
      run_task('426')
    end

    it 'should abort if a commit between fails' do
      @helper.should_receive(:apply_commit).once.with("f665dcd").and_return(false)
      @helper.should_not_receive(:apply_commit).with("8a65b36")
      lambda { run_task('426') }.should raise_error(RuntimeError, /Cannot apply commit f665dcd, aborting/)
    end
  end

  context 'with multiple supplied tickets' do
    before :each do
      @helper = mock(GitHelper, :null_object => true)
      GitHelper.stub!(:new).and_return(@helper)
    end

    it 'should find the relevant commits form master' do
      @helper.should_receive(:find_by_tickets).with("528", "700").and_return(mocked_commits_multiple)
      out, _ = run_task("528:700")
      out.should match(/Applying commit 1e809b1/)
    end
  end

  private
  def run_task(arg = nil)
    capture_output do
      Rake::Task['cherry'].reenable
      Rake::Task['cherry'].invoke(arg)
    end
  end

  def mocked_commits
    <<-EOF
f665dcd Ticket #426: Fixing something
8a65b36 Ticket #426
cea9613 Ticket #426
EOF
  end

  def mocked_commits_multiple
    <<-EOF
54add46 Ticket #700
6cc1e72 Ticket #700
ad55797 Ticket #700
1e809b1 Ticket #528
7d7762a Ticket #528
473efbb Ticket #528
2b5866d Ticket #528
EOF
  end
end
