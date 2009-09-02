module Spec
  module Runner
    class Configuration
      def enable_hornsby(options = {})
        Hornsby.load(options)

        include(Hornsby::Helper)
        before do
          Hornsby.setup(self)
        end
        after do
          Hornsby.teardown
        end
      end
    end
  end
end