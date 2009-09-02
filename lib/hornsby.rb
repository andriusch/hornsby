require File.join(File.dirname(__FILE__), 'hornsby/context')
require File.join(File.dirname(__FILE__), 'hornsby/helper')
require File.join(File.dirname(__FILE__), 'hornsby/errors')

class Hornsby
  SCENARIO_FILES = [nil, 'spec', 'test'].product(['hornsby_scenarios', 'hornsby_scenario']).map do |path|
    path = File.join(*path.compact)
    ["#{path}.rb", File.join(path, "*.rb")]
  end.flatten

  @@delete_sql = "DELETE FROM %s"

  cattr_reader :scenarios
  cattr_accessor :executed_scenarios
  # @@namespaces = {}
  @@scenarios = {}
  @@executed_scenarios = Set.new
  @@global_executed_scenarios = []

  @@global_context = Hornsby::Context
  @@context = nil

  def self.framework_root
    @@framework_root ||= RAILS_ROOT rescue Rails.root rescue Merb.root rescue nil
  end

  def self.configure_rspec(config, options = {})
    load(options)

    config.include(Hornsby::Helper)
    config.before do
      Hornsby.setup(self)
    end
    config.after do
      Hornsby.teardown
    end
  end

  def self.configure_test(config, options)
    load(options)
    
    config.send(:include, Hornsby::Helper)
    config.setup do
      Hornsby.setup(self)
    end
    config.teardown do
      Hornsby.teardown
    end
  end

  def self.setup(current_context)
    @@context = @@global_context.clone
    @@executed_scenarios = Set.new(@@global_executed_scenarios)
    copy_ivars(current_context, true)
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.transaction_joinable = false
    ActiveRecord::Base.connection.begin_db_transaction
  end

  def self.teardown
    ActiveRecord::Base.connection.rollback_db_transaction
    ActiveRecord::Base.connection.decrement_open_transactions
  end

  def self.build(*names)
    scenarios = names.map {|name| @@scenarios[name.to_sym] or raise ScenarioNotFoundError, name}

    scenarios.each {|s| s.build}
  end

  def self.load(options = {})
    return unless @@scenarios.empty?

    delete_tables
    @@framework_root = options[:root] if options[:root]
    load_scenarios_files(options[:filename] || SCENARIO_FILES)

    @@context = @@global_context
    @@global_scenarios = Hornsby.build(options[:scenarios]) if options[:scenarios]
    @@global_executed_scenarios = @@executed_scenarios.to_a
  end

  def self.load_scenarios_files(*patterns)
    patterns.flatten!
    patterns.collect! {|pattern| File.join(framework_root, pattern)} if framework_root
    
    patterns.each do |pattern|
      unless (files = Dir.glob(pattern)).empty?
        files.each{|f| self.module_eval File.read(f)}
        return
      end
    end
    
    raise "Scenarios file not found! Put scenarios in #{patterns.join(' or ')} or pass custom filename with :filename option"
  end

  def self.scenario(scenario, &block)
    self.new(scenario, &block)
  end

  def self.delete_tables(*args)
    args = tables if args.blank?
    args.each { |t| ActiveRecord::Base.connection.delete(@@delete_sql % t)  }
  end

  def self.tables
    ActiveRecord::Base.connection.tables - skip_tables
  end

  def self.skip_tables
    %w( schema_info schema_migrations )
  end

  def self.copy_ivars(to, reload = false)
    @@context.copy_ivars(to, reload)
  end

  attr_reader :scenario

  def initialize(scenario, &block)
    @scenario, @parents = parse_name(scenario)
    @block = block

    @@scenarios[@scenario] = self
  end

  def parse_name(name)
    case name
      when Hash
        return name.keys.first.to_sym, [name.values.first].flatten.map{|sc| parse_name(sc).first}
      when Symbol, String
        return name.to_sym, []
      else
        raise TypeError, "Pass scenarios names as strings or symbols only, cannot build scenario '#{name.inspect}'"
    end  
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
      parent = @@scenarios[p] or raise ScenarioNotFoundError, p

      parent.build_parent_scenarios(context)
      parent.build_scenario(context)
    end
  end

  def surface_errors
    yield
  rescue StandardError => error
    puts
    say "There was an error building scenario '#{@scenario}'", error.inspect
    puts
    puts error.backtrace
    puts
    raise error
  end
end