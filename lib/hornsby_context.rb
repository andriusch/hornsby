module HornsbyContext
  @@global_variables = Set.new

  def self.execute(global, &block)
    iv = instance_variables
    module_exec(&block)
    @@global_variables += instance_variables - iv if global
  end

  def self.copy_ivars(to, reload = false)
    @@global_variables.each {|iv| instance_variable_get(iv).reload if instance_variable_get(iv).respond_to?(:reload)} if reload
    instance_variables.each {|iv| to.instance_variable_set(iv, instance_variable_get(iv)) }
  end
end