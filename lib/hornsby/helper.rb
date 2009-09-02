class Hornsby
  module Helper
    def hornsby_scenario(*names)
      Hornsby.build(*names)
      Hornsby.copy_ivars(self)
    end

    def hornsby_clear(*args)
      options = args.extract_options!
      Hornsby.delete_tables(*args)

      if options[:undo] == :all
        Hornsby.executed_scenarios.clear
      else
        undo = [options[:undo]].flatten.compact
        unless (not_found = undo - Hornsby.executed_scenarios.to_a).blank?
          raise(ArgumentError, "Scenario(s) #{not_found} not found")
        end
        Hornsby.executed_scenarios -= undo
      end
    end
  end
end