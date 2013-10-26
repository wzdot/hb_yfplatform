module ActiveScaffoldExpired
	extend ActiveSupport::Concern

  attr_writer :skip_expire_fragment

  def skip_expire_fragment
    @skip_expire_fragment ||= false
  end

	module ClassMethods
    def expired_active_scaffold_cache
      after_update do
        if self.changed?
          ctrl_name = self.class.to_s.tableize
          unless skip_expire_fragment
            ActionController::Base.new.expire_fragment /active_scaffold_fragment_#{ctrl_name}_.*/
          end
        end
      end

      after_create do
      	ctrl_name = self.class.to_s.tableize
        unless skip_expire_fragment
          ActionController::Base.new.expire_fragment /active_scaffold_fragment_#{ctrl_name}_.*/
        end
      end

      after_destroy do
      	ctrl_name = self.class.to_s.tableize
        unless skip_expire_fragment
          ActionController::Base.new.expire_fragment /active_scaffold_fragment_#{ctrl_name}_.*/
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveScaffoldExpired)