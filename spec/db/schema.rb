ActiveRecord::Schema.define(:version => 0) do
  create_table :fruits do |t|
    t.string :species
    t.integer :average_diameter
  end
end
