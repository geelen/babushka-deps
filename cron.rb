meta :crontab do
  accepts_list_for :user
  accepts_list_for :lines_to_add
  template {
    helper(:crontab) { "/var/spool/cron/crontabs" / user.first }
    met? { lines_to_add.all? { |line| sudo("grep '#{line.to_s.chomp.strip}' #{crontab}") } }
    meet { append_to_file lines.join("\n") + "\n\n", crontab, :sudo => !File.writable?(crontab) }
  }
end
