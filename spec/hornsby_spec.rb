require File.dirname(__FILE__) + '/spec_helper'

describe Hornsby, "with just_apple scenario" do
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

describe Hornsby, "with bananas_and_apples scenario" do
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

describe Hornsby, "with fruit scenario" do
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

describe Hornsby, 'with preloaded cherry scenario' do
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
end

describe Hornsby, 'with many apples scenario' do
  before do
    hornsby_scenario :many_apples, :cherry
  end

  it "should create only one apple" do
    puts Hornsby.send(:class_variable_get, :@@executed_scenarios).inspect
    Fruit.all(:conditions => 'species = "apple"').count.should == 1
  end

  it "should create only one cherry even if it was preloaded" do
    Fruit.all(:conditions => 'species = "cherry"').count.should == 1
  end
end

#describe Hornsby, "with pitted namespace" do
#  before do
#    Hornsby.build('pitted:peach').copy_ivars(self)
#  end
  
#  it "should have @peach" do
#    @peach.species.should == 'peach'
#  end
#end