scenario(:just_apple) do
  @apple = Fruit.create! :species => 'apple'
end

scenario(:many_apples => [:just_apple, :just_apple, :just_apple])

scenario(:bananas_and_apples => :just_apple) do
  @banana = Fruit.create! :species => 'banana'
end

scenario(:just_orange) do
  @orange = Fruit.create! :species => 'orange'
end

scenario(:fruit => [:just_apple,:just_orange]) do
  @fruit = [@orange,@apple]
end

scenario(:bananas_and_apples_and_oranges => [:bananas_and_apples,:just_orange]) do
  @fruit = [@orange,@apple,@banana]
end

scenario(:cherry) do
  @cherry = Fruit.create! :species => 'cherry', :average_diameter => 3
end

scenario(:big_cherry => :cherry) do
  @big_cherry = Fruit.create! :species => @cherry.species, :average_diameter => 7
end

scenario(:cherry_basket => [:big_cherry, :cherry]) do
  @basket = [@cherry, @big_cherry]
end


scenario :parent_not_existing => :not_existing

# Hornsby.namespace(:pitted_fruit) do
#   scenario(:peach) do
#     @peach = Fruit.create! :species => 'peach'
#   end
#
#   scenario(:nectarine) do
#     @nectarine = Fruit.create! :species => 'nectarine'
#   end
# end