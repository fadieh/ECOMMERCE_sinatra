class Item

	include DataMapper::Resource

	property :id,				Serial
	property :item_name,		String
	property :brand,			String
	property :price,			Integer
	property :stock,			Integer

end