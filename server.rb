require 'sinatra'
require 'data_mapper'
require 'rack-flash'

env = ENV["RACK_ENV"] || "development"

# telling datamapper to use a postgres database on local host.
DataMapper.setup(:default, "postgres://localhost/eastjam_#{env}")

# this needs to be done after DataMapper has initialised.
require './lib/item'
require './lib/user'

# After declaring models, should finalise them
DataMapper.finalize

# However, database tables don't exist yet, tell datamapper to create them
DataMapper.auto_upgrade!

class Ecommerce < Sinatra::Base

	set :views, Proc.new {File.join(root, 'views')}
	set :public_dir, Proc.new {File.join(root, 'public')}
	set :public_folder, 'public'

	enable :sessions
	set :session_secret, 'super secret'

	use Rack::Flash

	# routing

	get '/' do
		@item = Item.all
		erb :index
	end

	get '/users/new' do
		@user = User.new
		erb :"users/new"
	end

	post '/users' do
		@user = User.create(:email => params[:email],
					:password => params[:password],
					:password_confirmation => params[:password_confirmation])
		if @user.save
			session[:user_id] = @user.id
			redirect to('/')
		else
			flash.now[:errors] = @user.errors.full_messages
			erb :"users/new"
		end
	end

	get '/sessions/new' do
		erb :"sessions/new"
	end

	post '/sessions' do
		email, password = params[:email], params[:password]
		user = User.authenticate(email, password)
		if user
			session[:user_id] = user.id
			redirect to('/')
		else
			flash[:errors] = ["The email or password is incorrect"]
			erb :"sessions/new"
		end
	end

	run! if app_file == $0

	helpers do

		def current_user
			@current_user ||= User.get(session[:user_id]) if session[:user_id]
		end

	end

end