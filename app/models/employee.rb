class Employee < ActiveRecord::Base
	expired_active_scaffold_cache
  belongs_to :region
end
