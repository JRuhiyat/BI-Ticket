# Create test user
User.find_or_create_by!(email: "4dm1n-01@example.com") do |user|
  user.name = "Admin User"
  user.password = "pwd001!@"
  user.password_confirmation = "pwd001!@"
end

[Ticket, ItemAffected, Category].each do |model|
  model.delete_all
  ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
end

# Create Categories and Item Affecteds
categories_data = {
  "EVENT SUPPORT - Highland Area" => [
    "Carpentry",
    "Carpet",
    "Concept Design",
    "Decoration Installation at Heigh",
    "Electric",
    "Furniture",
    "Plants"
  ],
  "CARPENTRY - Highland Area" => [
    "Boxes / crates",
    "Ceiling",
    "Door and screen",
    "Fence",
    "Furniture",
    "Kitchen set",
    "Tile",
    "Wall",
    "White Board",
    "Windows"
  ],
  "EXTERIOR - Highland Area" => [
    "Canopy/ Pation",
    "Demolition/ Dismantling",
    "Floor Vynil/ Tile",
    "Gutter/ Lisplank/ Fascia",
    "Other Exterior Works",
    "Painting Exterior",
    "Re-Painting Exterior",
    "Roofing",
    "Support Manlift/ JLG",
    "Support Schafolding",
    "Wall Exterior",
    "Wood Fence/ Composite Fence"
  ],
  "PAINTING - Highland Area" => [
    "Paint/ varnish furniture",
    "Painting interior",
    "Repaint/ varnish furniture",
    "Repaint interior"
  ]
}

categories_data.each do |category_name, item_names|
  category = Category.find_or_create_by!(name: category_name)
  
  item_names.each do |item_name|
    ItemAffected.find_or_create_by!(
      name: item_name,
      category: category
    )
  end
end

