#meta :crontab do
#  accepts_list_for :user
#  accepts_list_for :lines_to_add
#  template {
#    met? {
#      existing_crontab = sudo "crontab -l", :as => user.first.to_s
#      lines_to_add.all? { |line| existing_crontab =~ Regexp.new(Regexp.escape(lines_to_add).gsub(/ +/," +")) }
#    }
#    meet { append_to_file lines_to_add.join("\n") + "\n\n", crontab, :sudo => !File.writable?(crontab) }
#  }
#end
