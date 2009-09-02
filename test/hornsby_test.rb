require File.dirname(__FILE__) + '/test_helper'
require 'shoulda'

class HornsbyTest < ActiveSupport::TestCase
  context "with just_apple scenario" do
    setup do
      hornsby_scenario :just_apple
    end

    should "create @apple" do
      assert(!(@apple.nil?))
    end

    should "create Fruit @apple" do
      assert(@apple.instance_of?(Fruit))
    end

    should "not create @banana" do
      assert(@banana.nil?)
    end

    should "have correct species" do
      assert(@apple.species == 'apple')
    end
  end

  context "with bananas_and_apples scenario" do
    setup do
      hornsby_scenario :bananas_and_apples
    end

    should "have correct @apple species" do
      assert(@apple.species == 'apple')
    end

    should "have correct @banana species" do
      assert(@banana.species == 'banana')
    end
  end

  context "with fruit scenario" do
    setup do
      hornsby_scenario :fruit
    end

    should "have 2 fruits" do
      assert(@fruit.size == 2)
    end

    should "have an @apple" do
      assert(@apple.species == 'apple')
    end

    should "have an @orange" do
      assert(@orange.species == 'orange')
    end

    should "have no @banana" do
      assert(@banana.nil?)
    end
  end

  context 'with preloaded cherry scenario' do
    should "have correct size after changed by second test" do
      assert(@cherry.average_diameter == 3)
      @cherry.update_attribute(:average_diameter, 1)
      assert(@cherry.average_diameter == 1)
    end

    should "have correct size" do
      assert(@cherry.average_diameter == 3)
      @cherry.update_attribute(:average_diameter, 5)
      assert(@cherry.average_diameter == 5)
    end

    should "create big cherry" do
      assert(@big_cherry.species == 'cherry')
    end
  end

  context 'hornsby_clear' do
    setup do
      hornsby_scenario :just_apple
    end

    should "clear scenarios when calling hornsby_clear" do
      hornsby_clear
      assert(Fruit.count == 0)
    end

    should "clear only tables passed" do
      Tree.create!(:name => 'oak')
      hornsby_clear :fruits
      assert(Tree.count == 1)
      assert(Fruit.count == 0)
    end

    should "mark scenarios as undone when passed :undone option" do
      hornsby_scenario :fruit
      hornsby_clear :undo => [:just_apple]
      assert(Fruit.count == 0)
      hornsby_scenario :fruit
      assert(Fruit.count == 1)
    end

    should "mark all scenarios as undone when passed :undone option as :all" do
      hornsby_scenario :fruit
      hornsby_clear :undo => :all
      assert(Fruit.count == 0)
      hornsby_scenario :fruit
      assert(Fruit.count == 2)
    end

    should "raise error when not executed scenarios passed to :undo option" do
      assert_raise(ArgumentError) do
        hornsby_clear :undo => :just_orange
      end
    end
  end

  context 'with many apples scenario' do
    setup do
      hornsby_scenario :many_apples, :cherry, :cherry_basket
    end

    should "create only one apple" do
      assert(Fruit.all(:conditions => 'species = "apple"').size == 1)
    end

    should "create only two cherries even if they were preloaded" do
      assert(Fruit.all(:conditions => 'species = "cherry"').size == 2)
    end

    should "contain cherries in basket if basket is loaded in test and cherries preloaded" do
      assert(@basket == [@cherry, @big_cherry])
    end
  end

  context 'transactions' do
    setup do
      hornsby_scenario :just_apple
    end

    should "drop only inner transaction" do
      assert(!(@apple.reload.nil?))
      begin
        ActiveRecord::Base.transaction do
          f = Fruit.create(:species => 'orange')
          assert(!(f.reload.nil?))
          raise 'some error'
        end
      rescue
      end
      assert(!(@apple.reload.nil?))
      assert(Fruit.find_by_species('orange').nil?)
    end
  end

  context 'errors' do
    should 'raise ScenarioNotFoundError when scenario could not be found' do
      assert_raise(Hornsby::ScenarioNotFoundError, "Scenario(s) not found 'not_existing'") do
        hornsby_scenario :not_existing
      end
    end
    
    should 'raise ScenarioNotFoundError when scenario parent could not be found' do
      assert_raise(Hornsby::ScenarioNotFoundError, "Scenario(s) not found 'not_existing'") do
        hornsby_scenario :parent_not_existing
      end
    end

    should 'raise TypeError when scenario name is not symbol or string' do
      assert_raise(TypeError, "Pass scenarios names as strings or symbols only, cannot build scenario '1'") do
        Hornsby.new(1)
      end
    end
  end

#describe "with pitted namespace" do
#  before do
#    Hornsby.build('pitted:peach').copy_ivars(self)
#  end

#  it "should have @peach" do
#    @peach.species.should == 'peach'
#  end
#end
end