require 'active_scaffold_expired'
require 'active_scaffold_finder'

module ActiveScaffold::Config
  class List < Base
    cattr_accessor :cached
    @@cached = false
  end
end

ActiveScaffold.set_defaults do |config| 
  list.cached = true
  list.per_page = 25
end