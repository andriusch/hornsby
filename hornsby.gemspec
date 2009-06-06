GEM_NAME = "hornsby"
GEM_VERSION = "0.1.0"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.authors = ["Andrius Chamentauskas", "Lachie Cox"]
  s.email = "sinsiliux@gmail.com"
  s.homepage = "http://github.com/sinsiliux/hornsby"
  s.platform = Gem::Platform::RUBY
  s.summary = "Fixtures replacement"
  s.files = [
    "lib/hornsby.rb",
    "tasks/hornsby_tasks.rake",
    "README.rdoc"
  ]
  s.require_path = "lib"
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/hornsby_spec.rb"
  ]
  s.has_rdoc = false
  s.add_dependency("rspec", ">= 1.2.0")
  s.add_dependency("activerecord", ">= 2.0.0")
end
