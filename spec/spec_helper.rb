require 'fileutils'
require 'activerecord'

spec_dir = File.dirname(__FILE__)
Dir.chdir spec_dir

ActiveRecord::Base.logger = Logger.new(spec_dir + "/debug.log")

databases = YAML::load(IO.read(spec_dir + "/db/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)
load(File.join(spec_dir, "db", "schema.rb"))

require 'spec/autorun'
require '../lib/hornsby'
require 'db/fruit'

Spec::Runner.configure do |config|
  Hornsby.configure_rspec(config, :filename => File.join(spec_dir, 'hornsby_scenario.rb'), :scenarios => :cherry)
end
