module HornsbyContext
  def self.execute(&block)
    module_exec(&block) if block
  end

  def self.copy_ivars(to, reload = false)
    instance_variables.each do |iv|
      v = instance_variable_get(iv)
      v.reload if reload and v.respond_to?(:reload)
      to.instance_variable_set(iv, v)
    end
  end
end