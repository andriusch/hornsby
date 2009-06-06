class Hornsby
  @@delete_sql = "DELETE FROM %s"

  def self.framework_root
    RAILS_ROOT rescue Rails.root rescue Merb.root rescue ''
  end

  cattr_reader :scenarios
  @@scenarios = {}
  @@executed_scenarios = Set.new
  cattr_reader :global_scenarios
  # @@namespaces = {}

  def self.configure_rspec(config, options = {})
    load(options[:filename])

    @@global_scenarios = Hornsby.build(options[:scenarios]) if options[:scenarios]

    config.include(HornsbySpecHelper)

    config.before do
      @@executed_scenarios = Set.new(@@global_scenarios.collect {|s| s.scenario })
      @@global_scenarios.each {|s| s.copy_ivars(self, true)} if @@global_scenarios
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
    scenarios_file ||= framework_root + '/spec/hornsby_scenarios.rb'
    self.module_eval File.read(scenarios_file)
  end

  def self.scenario(scenario, &block)
    self.new(scenario, &block)
  end

  def self.namespace(name, &block)
  end

  def self.reset!
    @@scenarios = {}
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
    @context = context = Module.new

    # TODO move this elsewhere
    context.module_exec do
      def self.method_missing(meth_id, *args, &block)
        begin
          rec = meth_id.to_s.classify.constantize.send(:create!, *args)
          yield(rec) if block_given?
        rescue
          super
        end
      end
    end

    ivars = context.instance_variables

    build_parent_scenarios(context)
    build_scenario(context)

    @context_ivars = context.instance_variables - ivars

    self
  end

  def build_scenario(context)
    surface_errors { context.module_eval(&@block) } unless @@executed_scenarios.include?(@scenario)
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

  def copy_ivars(to, reload = false)
    @context_ivars.each do |iv|
      v = @context.instance_variable_get(iv)
      v.reload if reload and v.respond_to?(:reload)
      to.instance_variable_set(iv, v)
    end
  end
end


module HornsbySpecHelper
  def hornsby_scenario(*names)
    Hornsby.build(*names).each {|s| s.copy_ivars(self)}
  end
end