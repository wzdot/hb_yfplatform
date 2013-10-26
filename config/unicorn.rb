# 应用程序目录
app_path = File.expand_path("../../", __FILE__)

# 系统内核数
core = `nproc` || '4'

working_directory app_path
worker_processes core.to_i
preload_app true
timeout 30

# 程序进程
listen "#{app_path}/pids/unicorn.socket"
pid "#{app_path}/pids/unicorn.pid"

# 启动用户权限
user 'yfplatform', 'yfplatform' 

# 设置部署环境
rails_env = ENV['RAILS_ENV'] || 'production'

# 日志存放路径
stderr_path "#{app_path}/log/unicorn.log"
stdout_path "#{app_path}/log/unicorn.log"

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
