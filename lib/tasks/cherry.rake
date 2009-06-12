task :cherry, :tickets do |t, args|
  args.with_defaults(:tickets => "")
  tickets = args.tickets

  fail "You must supply at least one ticket number" if tickets.empty?
end
