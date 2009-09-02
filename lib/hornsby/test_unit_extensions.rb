module Test
  module Unit
    class TestCase
      def run_with_hornsby(result, &progress_block)
        Hornsby.setup(self)
        run_without_hornsby(result, &progress_block)
        Hornsby.teardown
      end

      def self.enable_hornsby(options = {})
        include Hornsby::Helper
        Hornsby.load(options)
        alias_method_chain :run, :hornsby
      end
    end
  end
end