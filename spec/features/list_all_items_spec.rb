require 'spec_helper'

feature "User browses the list of links" do

	before(:each) {
		Item.create(:item_name => "Adidas Tshirt",
					:price => 20,
					:brand => "Adidas",
					:stock => 10)
	}

	scenario "Items are listed on the home page" do
		visit '/'
		save_and_open_page
		expect(page).to have_content("Adidas Tshirt")
		expect(page).to have_content("Price: 20")
		expect(page).to have_content("Adidas")
	end

end