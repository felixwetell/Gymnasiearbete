require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'bcrypt'
require 'warden'

set :port, 4568
#set :public_folder, './site/public'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"

class User
  include DataMapper::Resource

  property :id       , Serial
  property :username , String
  property :email    , String
  property :password , String, :length => 60
  property :salt     , String, :length => 29

  property :created_at , DateTime
  property :updated_at , DateTime
end


configure :development do
  DataMapper.auto_upgrade!
  #DataMapper.auto_migrate!
end

DataMapper.finalize

enable :sessions

helpers do

  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end

  def username
    return session[:username]
  end

end

get '/meow' do
  #@hej = user.created_at
  erb :meow
end

get '/logout' do
  session[:username] = nil
  redirect '/'
end

post '/form' do

  if User.get(1).password == BCrypt::Engine.hash_secret(params['password'], User.get(1).salt)
    session[:username] = params[:username]
  end

  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params['password'], password_salt)
  username = params['username']
  user = User.new username: username, email: "meow@meow.se", password: password_hash, salt: password_salt
  user.save
  redirect to('/test')
end

before '/test' do
  authenticate!
end

get '/test' do
  @name = User.all
  erb :test
end



