require File.join(File.dirname(__FILE__), 'hornsby_context')

class Hornsby
  @@delete_sql = "DELETE FROM %s"

  def self.framework_root
    RAILS_ROOT rescue Rails.root rescue Merb.root rescue ''
  end

  cattr_reader :scenarios
  # @@namespaces = {}
  @@scenarios = {}
  @@executed_scenarios = Set.new
  @@global_executed_scenarios = []

  @@global_context = HornsbyContext
  @@context = nil

  def self.configure_rspec(config, options = {})
    load(options[:filename])

    @@context = @@global_context
    @@global_scenarios = Hornsby.build(options[:scenarios]) if options[:scenarios]
    @@global_executed_scenarios = @@executed_scenarios.to_a

    config.include(HornsbySpecHelper)

    config.before do
      @@context = @@global_context.clone
      @@executed_scenarios = Set.new(@@global_executed_scenarios)
      Hornsby.copy_ivars(self, true)
      ActiveRecord::Base.connection.increment_open_transactions
      ActiveRecord::Base.connection.transaction_joinable = false
      ActiveRecord::Base.connection.begin_db_transaction
    end

    config.after do
      ActiveRecord::Base.connection.rollback_db_transaction
      ActiveRecord::Base.connection.decrement_open_transactions
    end
  end

  def self.build(*names)
    scenarios = names.map {|name| @@scenarios[name.to_sym] or raise "scenario #{name} not found"}

    scenarios.each {|s| s.build}
  end

  def self.[](name)
  end

  def self.load(scenarios_file=nil)
    return unless @@scenarios.empty?

    delete_tables
    scenarios_file ||= File.join(framework_root, 'spec', 'hornsby_scenarios.rb')
    self.module_eval File.read(scenarios_file)
  end

  def self.scenario(scenario, &block)
    self.new(scenario, &block)
  end

  def self.delete_tables
    tables.each { |t| ActiveRecord::Base.connection.delete(@@delete_sql % t)  }
  end

  def self.tables
    ActiveRecord::Base.connection.tables - skip_tables
  end

  def self.skip_tables
    %w( schema_info )
  end

  def self.copy_ivars(to, reload = false)
    @@context.copy_ivars(to, reload)
  end

  attr_reader :scenario

  def initialize(scenario, &block)
    case scenario
      when Hash
        parents = scenario.values.first
        @parents = Array === parents ? parents : [parents]
        scenario = scenario.keys.first
      when Symbol, String
        @parents = []
      else
        raise "I don't know how to build `#{scenario.inspect}'"
    end

    @scenario = scenario.to_sym
    @block    = block

    @@scenarios[@scenario] = self
  end

  def say(*messages)
    puts messages.map { |message| "=> #{message}" }
  end

  def build
    build_parent_scenarios(@@context)
    build_scenario(@@context)
    self
  end

  def build_scenario(context)
    surface_errors { context.execute(&@block) } unless @@executed_scenarios.include?(@scenario)
    @@executed_scenarios << @scenario
  end

  def build_parent_scenarios(context)
    @parents.each do |p|
      parent = self.class.scenarios[p] or raise "parent scenario [#{p}] not found!"

      parent.build_parent_scenarios(context)
      parent.build_scenario(context)
    end
  end

  def surface_errors
    yield
  rescue StandardError => error
    puts
    say "There was an error building scenario `#{@scenario}'", error.inspect
    puts
    puts error.backtrace
    puts
    raise error
  end
end


module HornsbySpecHelper
  def hornsby_scenario(*names)
    Hornsby.build(*names)
    Hornsby.copy_ivars(self)
  end

  def hornsby_clear
    Hornsby.delete_tables
  end
end
