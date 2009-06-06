require 'fileutils'
require 'activerecord'

spec_dir = File.dirname(__FILE__)
Dir.chdir spec_dir

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read("db/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)
load(File.join("db", "schema.rb"))

require 'spec/autorun'
require '../lib/hornsby'
require 'db/fruit'

Spec::Runner.configure do |config|
  Hornsby.configure_rspec(config, :filename => File.join('hornsby_scenario.rb'), :scenarios => :big_cherry)
end
