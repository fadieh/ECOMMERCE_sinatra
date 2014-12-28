require 'sinatra'
require 'data_mapper'
require 'rack-flash'
require 'rest_client'

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

	set :show_exceptions, false

	enable :sessions
	set :session_secret, 'super secret'

	use Rack::Flash
	use Rack::MethodOverride

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

	delete '/sessions' do
		flash[:notice] = "Good bye!"
		session[:user_id] = nil
		redirect to('/')
	end

	get '/users/reset_password' do
		erb :"users/reset_password"
	end

	def send_reset_email(email, token)
		RestClient.post "https://api:key-9697e2ab8b43fcf3bcef4b16a489d1fc"\
  		"@api.mailgun.net/v2/sandbox4e7aa7e546fe470fa8374cfef666b223.mailgun.org/messages", 
		:from => "Team <postmaster@sandbox4e7aa7e546fe470fa8374cfef666b223.mailgun.org>",
		:to => "#{email}",
		:subject => "Reset your password",
		:text => "Test to see if it has taken email params. http://localhost:9292/users/reset_password/#{token}"
	end

	post '/users/reset' do
		email = params[:email]
		@email = email
		user = User.first(:email => email)
		if user
			user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
			@token = user.password_token
			user.password_token_timestamp = Time.now
			user.save
			send_reset_email(@email, @token)
			flash[:notice] = "Your email to reset your password has been sent!"
			erb :"users/reset_password"
		else
			flash[:notice] = "Sorry, we do not recognise that email address. Please try again."
			erb :"users/reset_password"
		end
	end

	get '/users/reset_password/:token' do
		token = params[:token]
		user = User.first(:password_token => token)
		if user
			erb :"users/reset_password_page"
		end
	end

	run! if app_file == $0

	helpers do

		def current_user
			@current_user ||= User.get(session[:user_id]) if session[:user_id]
		end

	end

end