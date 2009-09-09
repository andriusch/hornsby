require File.dirname(__FILE__) + '/spec_helper'

describe Hornsby do
  describe "scenario files" do
    it "should be loaded from specified dirs" do
      Hornsby::SCENARIO_FILES.should == ["hornsby_scenarios.rb", "hornsby_scenarios/*.rb", "hornsby_scenario.rb", "hornsby_scenario/*.rb", "spec/hornsby_scenarios.rb", "spec/hornsby_scenarios/*.rb", "spec/hornsby_scenario.rb", "spec/hornsby_scenario/*.rb", "test/hornsby_scenarios.rb", "test/hornsby_scenarios/*.rb", "test/hornsby_scenario.rb", "test/hornsby_scenario/*.rb"]
    end
  end

  describe "with just_apple scenario" do
    before do
      hornsby_scenario :just_apple
    end

    it "should create @apple" do
      @apple.should_not be_nil
    end

    it "should create Fruit @apple" do
      @apple.should be_instance_of(Fruit)
    end

    it "should not create @banana" do
      @banana.should be_nil
    end

    it "should have correct species" do
      @apple.species.should == 'apple'
    end
  end

  describe "with bananas_and_apples scenario" do
    before do
      hornsby_scenario :bananas_and_apples
    end

    it "should have correct @apple species" do
      @apple.species.should == 'apple'
    end

    it "should have correct @banana species" do
      @banana.species.should == 'banana'
    end
  end

  describe "with fruit scenario" do
    before do
      hornsby_scenario :fruit
    end

    it "should have 2 fruits" do
      @fruit.should have(2).items
    end

    it "should have an @apple" do
      @apple.species.should == 'apple'
    end

    it "should have an @orange" do
      @orange.species.should == 'orange'
    end

    it "should have no @banana" do
      @banana.should be_nil
    end
  end

  describe 'with preloaded cherry scenario' do
    it "should have correct size after changed by second test" do
      @cherry.average_diameter.should == 3
      @cherry.update_attribute(:average_diameter, 1)
      @cherry.average_diameter.should == 1
    end

    it "should have correct size" do
      @cherry.average_diameter.should == 3
      @cherry.update_attribute(:average_diameter, 5)
      @cherry.average_diameter.should == 5
    end

    it "should create big cherry" do
      @big_cherry.species.should == 'cherry'
    end
  end

  describe 'hornsby_clear' do
    before do
      hornsby_scenario :just_apple
    end

    it "should clear scenarios when calling hornsby_clear" do
      hornsby_clear
      Fruit.count.should == 0
    end

    it "should clear only tables passed" do
      Tree.create!(:name => 'oak')
      hornsby_clear :fruits
      Tree.count.should == 1
      Fruit.count.should == 0
    end

    it "should mark scenarios as undone when passed :undone option" do
      hornsby_scenario :fruit
      hornsby_clear :undo => [:just_apple]
      Fruit.count.should == 0
      hornsby_scenario :fruit
      Fruit.count.should == 1
    end

    it "should mark all scenarios as undone when passed :undone option as :all" do
      hornsby_scenario :fruit
      hornsby_clear :undo => :all
      Fruit.count.should == 0
      hornsby_scenario :fruit
      Fruit.count.should == 2
    end

    it "should raise error when not executed scenarios passed to :undo option" do
      lambda {
        hornsby_clear :undo => :just_orange
      }.should raise_error(ArgumentError)
    end
  end

  describe 'with many apples scenario' do
    before do
      hornsby_scenario :many_apples, :cherry, :cherry_basket
    end

    it "should create only one apple" do
      Fruit.all(:conditions => 'species = "apple"').size.should == 1
    end

    it "should create only two cherries even if they were preloaded" do
      Fruit.all(:conditions => 'species = "cherry"').size.should == 2
    end

    it "should contain cherries in basket if basket is loaded in test and cherries preloaded" do
      @basket.should == [@cherry, @big_cherry]
    end
  end

  describe 'transactions' do
    before do
      hornsby_scenario :just_apple
    end

    it "should drop only inner transaction" do
      @apple.reload.should_not be_nil
      begin
        ActiveRecord::Base.transaction do
          f = Fruit.create(:species => 'orange')
          f.reload.should_not be_nil
          raise 'some error'
        end
      rescue
      end
      @apple.reload.should_not be_nil
      Fruit.find_by_species('orange').should be_nil
    end
  end

  describe 'errors' do
    it 'should raise ScenarioNotFoundError when scenario could not be found' do
      lambda {
        hornsby_scenario :not_existing
      }.should raise_error(Hornsby::ScenarioNotFoundError, "Scenario(s) not found 'not_existing'")
    end
    
    it 'should raise ScenarioNotFoundError when scenario parent could not be found' do
      lambda {
        hornsby_scenario :parent_not_existing
      }.should raise_error(Hornsby::ScenarioNotFoundError, "Scenario(s) not found 'not_existing'")
    end

    it 'should raise TypeError when scenario name is not symbol or string' do
      lambda {
        Hornsby.new(1)
      }.should raise_error(TypeError, "Pass scenarios names as strings or symbols only, cannot build scenario '1'")
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

