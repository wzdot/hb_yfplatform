set :application, 'yfplatform'
set :keep_releases, 1

set :user, 'yfplatform'
set :password, 'yfplatform603'
set :user_home, "/home/#{user}"
set :use_sudo, false
set :root_password, fetch(:root_password, '')
set :root_password, ENV['root_password']

set :opt_path, '/opt/local'

set :scm, :git
set :repository,  'git@greatms.com:yfplatform.git'
set :branch, ENV['branch'] || 'master'
set :host, fetch(:host, '')
server host, :app, :web, :db, :primary => true

set :deploy_to, "#{user_home}/app"        #部署到远程机器的路径
set :rails_env, :production

set :ruby_version, '1.9.3-p392'
set :rvm_ruby_string, "#{ruby_version}@#{application}"
set :rvm_type, :user

default_run_options[:shell] = '/bin/bash'
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :sidekiq_pid, "#{shared_path}/pids/sidekiq.pid"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

def with_user(new_user, new_pass, &block)
  old_user, old_pass = user, password
  set :user, new_user
  set :password, new_pass
  close_sessions
  yield
  set :user, old_user
  set :password, old_pass
  close_sessions
end
 
def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

namespace :deploy do
  before 'deploy:setup', 'setup:all'
  before 'deploy:setup', 'rvm:install_rvm'
  before 'deploy:setup', 'rvm:install_ruby'
  after 'rvm:install_ruby', 'rvm:create_gemset'
  after 'deploy:setup', 'nginx:restart'
  after 'deploy:update', 'deploy:cleanup'
  after 'deploy:update', 'deploy:migrate'
  before 'sidekiq:start', 'memcached:start'
  before 'sidekiq:start', 'redis:start'
  after 'sidekiq:stop', 'memcached:stop'
  after 'sidekiq:stop', 'redis:stop'
  after 'deploy:start', 'unicorn:start'
  after 'deploy:stop', 'unicorn:stop'
end

namespace :db do
  task :init do
    run("cd #{deploy_to}/current && bundle exec rake RAILS_ENV=production db:seed")
  end
end

namespace :memcached do
  task :start do
    run '/etc/init.d/memcached start'
  end

  task :stop do
    run '/etc/init.d/memcached stop'
  end

  task :restart do
    stop
    start
  end
end

namespace :redis do
  task :start do
    run '/etc/init.d/redisd start'
  end

  task :stop do
    run '/etc/init.d/redisd stop'
  end

  task :restart do
    stop
    start
  end
end

namespace :nginx do
  task :start do
    with_user('root', root_password) do
      run '/etc/init.d/nginxd start'
    end
  end

  task :stop do
    with_user('root', root_password) do
      run '/etc/init.d/nginxd stop'
    end
  end

  task :restart do
    with_user('root', root_password) do
      run '/etc/init.d/nginxd stop && /etc/init.d/nginxd start'
    end
  end
end

namespace :setup do
  task :all do
    rpm
    user
    init_dir
    pub_key
    mysql
    memcached
    redis
    nginx
    yfcam
    src_ruby
    init_conf
  end

  task :rpm do
    with_user('root', root_password) do
      run 'yum -y install git patch gcc-c++ readline-devel zlib-devel libyaml-devel libffi-devel openssl-devel autoconf automake libtool bison libxml2-devel libxslt-devel libevent-devel pcre-devel libcurl-devel ImageMagick-c++-devel mysql-devel sqlite-devel boost-regex boost-system boost-date-time boost-thread cmake'
      upload "settings/libyaml-0.1.4-1.el6.rf.x86_64.rpm", "/root/libyaml-0.1.4-1.el6.rf.x86_64.rpm"
      upload "settings/libyaml-devel-0.1.4-1.el6.rf.x86_64.rpm", "/root/libyaml-devel-0.1.4-1.el6.rf.x86_64.rpm"
      run 'rpm --force -ivh libyaml-0.1.4-1.el6.rf.x86_64.rpm'
      run 'rpm --force -ivh libyaml-devel-0.1.4-1.el6.rf.x86_64.rpm'
      run 'rm -rf libyaml-*.rpm'
    end
  end

  task :user do
    with_user('root', root_password) do
      run "id -u #{application} &>/dev/null || useradd #{application} -p \\$6\\$E4eS/xhb\\$ER6eDWtbmLbOqZJxrEmhHxzLRh5I40odszLAhkTluEcn9OhBZycZCOKPEYjKaMYWLP1IUCbcxikXX.xXofhsJ/"
      run 'id -u mysql &>/dev/null || useradd mysql -M'
    end
  end

  task :init_dir do
    with_user('root', root_password) do
      run "mkdir -p #{opt_path} && chown #{application}:#{application} #{opt_path}"
    end
    run "mkdir -p #{shared_path}/system/uploads/data/{irimages,irps,outlines,standards,tmp}"
  end

  task :pub_key do
    run 'mkdir -p .ssh'
    run '(curl http://greatms.com/uploads/note/attachment/953/id_rsa > .ssh/id_rsa) && chmod 600 .ssh/id_rsa'
    run '(curl http://greatms.com/uploads/note/attachment/951/id_rsa.pub > .ssh/id_rsa.pub) && chmod 644 .ssh/id_rsa.pub'
    run 'touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys'
  end

  task :mysql do
    version = '5.5.30'
    release = "#{current_task.name}-#{version}"
    with_user('root', root_password) do
      upload "settings/#{release}.tar.gz", "/root/#{release}.tar.gz"
      run "cd /root && tar -xf #{release}.tar.gz && cd #{release} && cmake . -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci && make && make install && cd - && rm -rf #{release}*"
      run "mkdir -p /var/lib/mysql && chown mysql:mysql /var/lib/mysql"
      upload "settings/my.cnf", "/etc/my.cnf"
      run "cd /usr/local/mysql && scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/var/lib/mysql --user=mysql"
      upload "settings/mysqld", "/etc/init.d/mysqld"
      run 'chmod +x /etc/init.d/mysqld && /etc/init.d/mysqld start && chkconfig --level 2345 mysqld on'
      upload "settings/init_yfplatform.sql", "/root/init_yfplatform.sql"
      run "mysql -uroot < /root/init_yfplatform.sql"
      run 'rm -rf /root/init_yfplatform.sql'
    end
  end

  task :memcached do
    version = '1.4.15'
    release = "#{current_task.name}-#{version}"
    run "(curl -L http://memcached.googlecode.com/files/#{release}.tar.gz | tar zx) && cd #{release} && ./configure --prefix=#{opt_path}/#{current_task.name} && make && make install && cd - && rm -rf #{release}"
  end

  task :redis do
    version = '2.6.10'
    release = "#{current_task.name}-#{version}"
    run "(curl -L http://redis.googlecode.com/files/#{release}.tar.gz | tar zx) && cd #{release} && make PREFIX=#{opt_path}/#{current_task.name} install && cp redis.conf #{opt_path}/#{current_task.name}/ && cd - && rm -rf #{release}"
  end

  task :nginx do
    version = "1.2.7"
    release = "#{current_task.name}-#{version}"
    run "( curl -L http://nginx.org/download/#{release}.tar.gz | tar zx) && cd #{release} && ./configure --prefix=#{opt_path}/#{current_task.name} --with-http_ssl_module && make && make install && cd - && rm -rf #{release}"
  end

  task :yfcam do
    run "mkdir -p #{opt_path}/yfcam/bin"
    upload 'settings/convert-irp-to-jpg', "#{opt_path}/yfcam/bin/convert-irp-to-jpg"
    run "chmod +x #{opt_path}/yfcam/bin/convert-irp-to-jpg"
  end

  task :src_ruby do
    run "mkdir -p #{user_home}/.rvm/archives/"
    upload "settings/ruby-#{ruby_version}.tar.bz2", "#{user_home}/.rvm/archives/ruby-#{ruby_version}.tar.bz2"
  end

  task :init_conf do
    upload 'settings/nginx.conf', "#{opt_path}/nginx/conf/nginx.conf"
    upload 'settings/redis.conf', "#{opt_path}/redis/redis.conf"
    with_user('root', root_password) do
      upload 'settings/memcached', "/etc/init.d/memcached"
      upload 'settings/nginxd', "/etc/init.d/nginxd"
      upload 'settings/redisd', "/etc/init.d/redisd"
      run "(chmod +x /etc/init.d/memcached) && (chmod +x /etc/init.d/nginxd)  && (chmod +x /etc/init.d/redisd) && chkconfig --level 2345 nginxd on"
    end
  end
end

require "rvm/capistrano"
require "bundler/capistrano"
require 'capistrano-unicorn'                             #必须在deply_to之后
require 'sidekiq/capistrano'
