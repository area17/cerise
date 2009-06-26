class GitHelper
  def find_by_tickets(*tickets)
    cmd = "git log --reverse --abbrev-commit --pretty=oneline --cherry-pick master... | grep -E \"\#\(#{tickets.join('|')}\)\\b\""
    `#{cmd}`
  end

  def apply_commit(sha)
    output = `git cherry-pick #{sha}`
    if $?.exitstatus == 0 || $?.exitstatus == 1
      return true
    else
      puts output
      return false
    end
  end
end

task :cherry, :tickets do |t, args|
  args.with_defaults(:tickets => "")
  helper = GitHelper.new

  tickets = args.tickets.split(':')

  fail "You must supply at least one ticket number" if tickets.empty?

  output = helper.find_by_tickets(*tickets)

  # build commit list
  commits = output.scan(/([a-f0-9]{7}).*?\s(.*)/i)

  commits.each do |sha, message|
    message =~ /\#(\d+)/
    puts "Applying commit #{sha} of Ticket ##{$1} (#{message})"
    unless result = helper.apply_commit(sha)
      fail "ERROR: Cannot apply commit #{sha}, aborting"
    end
  end
end
