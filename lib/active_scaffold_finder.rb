module ActiveScaffoldFinder
  extend ActiveSupport::Concern
  
  included do
    alias :origin_find_page :find_page

    def find_page(options = {})
      options.assert_valid_keys :sorting, :per_page, :page, :count_includes, :pagination
      options[:per_page] ||= 999999999
      options[:page] ||= 1
      options.merge!({:cached => active_scaffold_config.list.cached})

      find_options = finder_options(options)

      if options[:cached]
        count = controller_name.classify.constantize.send(:where, active_scaffold_conditions[0]).count
        pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
          controller_name.classify.constantize.send(:where, active_scaffold_conditions[0]).limit(per_page).offset(offset)
        end
      else
        # NOTE: we must use :include in the count query, because some conditions may reference other tables
        if options[:pagination] && options[:pagination] != :infinite
          count = count_items(find_options, options[:count_includes])
        end

        klass = beginning_of_chain

        # we build the paginator differently for method- and sql-based sorting
        if options[:sorting] and options[:sorting].sorts_by_method?
          pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
            sorted_collection = sort_collection_by_column(append_to_query(klass, find_options).all, *options[:sorting].first)
            sorted_collection = sorted_collection.slice(offset, per_page) if options[:pagination]
            sorted_collection
          end
        else
          pager = ::Paginator.new(count, options[:per_page]) do |offset, per_page|
            find_options.merge!(:offset => offset, :limit => per_page) if options[:pagination]
            append_to_query(klass, find_options).all
          end
        end
      end
      pager.page(options[:page])
    end
  end
end

ActiveScaffold::Finder.send(:include, ActiveScaffoldFinder)