require 'rubygems'
require 'fileutils'
require 'activerecord'
require 'test/unit'
require 'active_record/test_case'
begin
  require 'mysqlplus'
rescue LoadError
end

spec_dir = File.join(File.dirname(__FILE__), '..', 'spec')

ActiveRecord::Base.logger = Logger.new("debug.log")

databases = YAML::load(IO.read(spec_dir + "/db/database.yml"))
db_info = databases[ENV["DB"] || "test"]
ActiveRecord::Base.establish_connection(db_info)
load(File.join(spec_dir, "db", "schema.rb"))

require spec_dir + '/../lib/hornsby'
require spec_dir + '/db/fruit'
require spec_dir + '/db/tree'

Hornsby.load(:filename => File.join('..', 'spec', 'hornsby_scenario.rb'), :scenarios => :big_cherry)
class ActiveSupport::TestCase
  include HornsbyHelper

  def setup
    Hornsby.setup(self)
  end

  def teardown
    Hornsby.teardown
  end
end