=begin
	操作前，root用户登录mysql的command模式，执行：
	GRANT ALL PRIVILEGES ON `yfplatform_development`.* TO 'rubyuser'@'%' IDENTIFIED BY 'rubyuser603' WITH GRANT OPTION;
	mysql> GRANT ALL PRIVILEGES ON `yfplatform_production`.* TO 'rubyuser'@'%' WITH GRANT OPTION;
	GRANT ALL PRIVILEGES ON `yfplatform_test`.* TO 'rubyuser'@'%' WITH GRANT OPTION;
	mysql> GRANT ALL PRIVILEGES ON `mysql`.`user` TO 'rubyuser'@'%';
	mysql> UPDATE `mysql`.`user` SET Reload_priv='Y' WHERE user='rubyuser';
	mysql> flush privileges;
=end

class TerminalUser < ActiveRecord::Base
	self.table_name = 'mysql.user'

	def self.grant(username, password, host = '%')
		TerminalUser.transaction do
			user = TerminalUser.find_by_User_and_Host(username, host)
			is_fresh = user ? false : true
			%w(development production test).each do |e|
				if is_fresh
					connection.execute "GRANT ALL PRIVILEGES ON yfplatform_#{e}.* TO '#{username}'@'#{host}' IDENTIFIED BY '#{password}'"
					is_fresh = false
				else
					connection.execute "GRANT ALL PRIVILEGES ON yfplatform_#{e}.* TO '#{username}'@'#{host}'"
				end
			end
		end
	end

	def self.revoke(username, host = '%')
		TerminalUser.transaction do
			user = TerminalUser.find_by_User_and_Host(username, host)
			is_fresh = user ? false : true

			%w(development production test).each do |e|
				unless is_fresh
					connection.execute "REVOKE ALL PRIVILEGES ON yfplatform_#{e}.* FROM '#{username}'@'#{host}'"
				end
			end
			connection.execute("DELETE FROM mysql.user WHERE user = '#{username}' AND host='#{host}'") unless is_fresh
			connection.execute('FLUSH PRIVILEGES')
		end
	end

	def self.edit(username, password, host = '%')
		TerminalUser.transaction do
			connection.execute("UPDATE mysql.user SET password=password('#{password}') WHERE user = '#{username}' AND host='#{host}'")
			connection.execute('FLUSH PRIVILEGES')
		end
	end
end