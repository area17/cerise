class GitHelper
  def find_by_tickets(*tickets)
    `git log --abbrev-commit --pretty=oneline master | grep -E "#{tickets.join('|')}"`
  end

  def apply_commit(sha)

  end
end

task :cherry, :tickets do |t, args|
  args.with_defaults(:tickets => "")
  tickets = args.tickets
  helper = GitHelper.new

  fail "You must supply at least one ticket number" if tickets.empty?

  output = helper.find_by_tickets(tickets)

  # build commit list
  commits = output.scan(/([a-f0-9]{7}).*?\s(.*)/i)

  commits.each do |sha, message|
    puts "Applying commit #{sha} of Ticket ##{tickets} (#{message})"
    unless result = helper.apply_commit(sha)
      fail "ERROR: Cannot apply commit #{sha}, aborting"
    end
  end
end
