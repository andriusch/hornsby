class Hornsby
  class ScenarioNotFoundError < NameError
    def initialize(*args)
      @scenarios = args
    end

    def to_s
      "Scenario(s) not found '#{@scenarios.join(',')}'"
    end
  end
end