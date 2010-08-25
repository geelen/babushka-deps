meta :crontab do
  accepts_list_for :lines_to_add
#  accepts_list_for L{[
#    ["* * * * *", var :command_one],
#    ["*/5 * * * *", var :command_two],
#  ]}
  helper(:existing_crontab) { shell "crontab -l" }
  template {
    met? {
      existing_crontab && lines_to_add.all? { |lines| lines.all? { |schedule, command|
        existing_crontab[command]
      }}
    }
    meet {
      shell("crontab -", :input => lines_to_add.map { |lines| lines.map { |schedule, command| "#{schedule}   #{command}" }.join("\n") }.join("\n"))
    }
  }
end
