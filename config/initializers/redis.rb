#$redis = Redis.new(:path => "/opt/local/redis/redis.sock", :driver => :hiredis, :expires_in => 30.minutes)
$redis = Redis.new( :host => "localhost", :driver => :hiredis, :expires_in => 30.minutes)
