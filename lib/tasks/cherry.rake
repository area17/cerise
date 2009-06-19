class GitHelper
  def find_by_tickets(*tickets)
    t = tickets.map { |ticket| "##{ticket}" }
    `git log --abbrev-commit --pretty=oneline master | grep -E "#{t.join('|')}"`
  end

  def apply_commit(sha)
    system "git cherry-pick #{sha}"
  end
end

task :cherry, :tickets do |t, args|
  args.with_defaults(:tickets => "")
  helper = GitHelper.new

  tickets = args.tickets.split(':')

  fail "You must supply at least one ticket number" if tickets.empty?

  output = helper.find_by_tickets(tickets)

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
