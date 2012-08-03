require 'earth'
require 'table_warnings'

module Earth
  module Model
    def Model.extended(target)
      target.extend SafeFinders
      target.extend Schema
      target.mattr_accessor :source_file
      self.registry << target
      target.source_file = caller.first.split(':').first

      extend_mining(target)
    end

    def Model.registry
      @registry ||= []
    end

    def Model.extend_mining(target)
      if Earth.mine_original_sources
        path = File.join(File.dirname(target.source_file), File.basename(target.source_file, '.rb'), 'data_miner')
        require path if File.exist?(path + '.rb')
        target.data_miner_script.prepend_once :process, :create_table!
      else
        target.data_miner_script.prepend_once :sql, "Brighter Planet's reference data", "http://data.brighterplanet.com/#{to_s.underscore.pluralize}.sql"
      end
      target.data_miner_script.append_once :process, :run_data_miner_on_parent_associations!
    end

    module Schema
      # http://ostermiller.org/findcomment.html
      COMMENT = %r{/\*(?:.|[\r\n])*?\*/}
      WHITESPACE = /\s+/
      SEMICOLON = / ?; ?/

      def create_table!(force = true)
        c = ActiveRecord::Base.connection_pool.checkout

        if c.table_exists?(table_name)
          return unless force
          c.drop_table table_name
        end

        statements = const_get(:TABLE_STRUCTURE).gsub(COMMENT, '').gsub(WHITESPACE, ' ').split(SEMICOLON).select(&:present?)

        statements.each do |sql|
          c.execute sql
        end

        # safely reset column information
        if c.respond_to?(:schema_cache)
          c.schema_cache.clear!
        end
        reset_column_information
        descendants.each do |descendant|
          descendant.reset_column_information
        end

        nil
      ensure
        ActiveRecord::Base.connection_pool.checkin c
      end
    end

    module SafeFinders
      # http://www.seejohncode.com/tag/rails/
      # Override due to implementation of regular find_in_batches conflicting using UUIDs
      def safe_find_in_batches(&block)
        return find_in_batches({}, &block) if relation.primary_key.is_a?(Arel::Attributes::Integer)

        batch_size = 1000
        offset = 0
        # Get the relation and keep going over it until there's nothing left
        relation = order("#{quoted_table_name}.#{quoted_primary_key} ASC").limit(batch_size)
        while (results = relation.offset(offset).limit(batch_size).all).any?
          unscoped { block.call(results) }
          offset += batch_size
        end
        nil
      end

      def safe_find_each
        safe_find_in_batches do |records|
          records.each { |record| yield record }
        end
      end
    end
  end
end
