GEM_NAME = "hornsby"
GEM_VERSION = "0.4.1"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.authors = ["Andrius Chamentauskas", "Lachie Cox"]
  s.email = "sinsiliux@gmail.com"
  s.homepage = "http://github.com/sinsiliux/hornsby"
  s.platform = Gem::Platform::RUBY
  s.summary = "Fixtures replacement with scenarios"
  s.files = %w{
    lib/hornsby.rb
    lib/hornsby/context.rb
    lib/hornsby/helper.rb
    lib/hornsby/errors.rb
    lib/hornsby/rspec_extensions.rb
    lib/hornsby/test_unit_extensions.rb
    lib/tasks/hornsby_tasks.rake
    README.rdoc
    LICENSE
  }
  s.require_path = "lib"
  s.test_files = %w{
    spec/spec_helper.rb
    spec/hornsby_spec.rb
    spec/hornsby_scenario.rb
    spec/db/fruit.rb
    spec/db/database.yml.example
    spec/db/schema.rb
    test/test_helper.rb
    test/hornsby_test.rb
  }
  s.has_rdoc = false
  s.add_dependency("activerecord", ">= 2.0.0")
end
