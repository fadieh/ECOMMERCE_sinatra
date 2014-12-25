require 'sinatra/base'

class Ecommerce < Sinatra::Base

	set :views, Proc.new {File.join(root, 'views')}
	set :public_dir, Proc.new {File.join(root, 'public')}
	set :public_folder, 'public'

	# routing

	get '/' do
		erb :index
	end

	run! if app_file == $0

end