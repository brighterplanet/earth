require 'earth'
require 'rake'
require 'active_record/connection_adapters/abstract/connection_specification'

module Earth
  class Tasks
    include Rake::DSL

    def initialize
      init_earth_tasks
      init_bare unless Object.const_defined?('Rails')

      namespace :db do
        task :create => 'earth:db:create'
        task :drop => 'earth:db:drop'
        task :migrate => 'earth:db:migrate'
        task :seed => 'earth:db:seed'
      end
    end

    def init_bare
      Object.const_set 'Rails', Earth

      require 'active_record'
      load 'active_record/railties/databases.rake'

      Rake::Task['db:load_config'].clear
      Rake::Task['db:create'].clear
      Rake::Task['db:drop'].clear
      Rake::Task['db:migrate'].clear
      Rake::Task['db:seed'].clear
    end

    def config
      spec = ENV['DATABASE_URL']
      resolver = ActiveRecord::Base::ConnectionSpecification::Resolver.new spec, {}
      resolver.spec.config.stringify_keys
    end
        
    def init_earth_tasks
      namespace :earth do
        namespace :db do
          task :create do
            create_database(config)
          end
          task :drop do
            drop_database_and_rescue(config)
          end
          task :load_config do
            Earth.connect
          end
          task :migrate => :load_config do
            Earth.reset_schemas!
          end
          task :seed => :load_config do
            Earth.run_data_miner!
          end
        end
      end
    end
  end
end
