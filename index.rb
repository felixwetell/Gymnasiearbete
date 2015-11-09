require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'dm-postgres-adapter'
require 'bcrypt'

#https://git.heroku.com/stark-earth-2441.git
set :port, 4568
#set :public_folder, './site/public'

#DataMapper.setup :default, "postgres://#{Dir.pwd}/database.db"
DataMapper.setup(:default, 'postgres://uuzfqirtsdlqch:Qngf4-VL2xom7pTmiBwaZH6L6f@ec2-54-217-240-205.eu-west-1.compute.amazonaws.com/d48tmpto2mh5fi')

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
  def authorized?
    if session[:username] == User.get(1).username
      return true
    else
      return false
    end
  end
end

get '*/private' do
    unless authorized?
        halt(401, 'Nooope')
    end
  erb :test
end

get '*/login' do
  erb :login
end

get '*/logout' do
  session[:username] = nil
  redirect '/'
end

post '/login' do
  if User.get(1).password == BCrypt::Engine.hash_secret(params['password'], User.get(1).salt)
    session[:username] = User.get(1).username
  end
  redirect to('/private')
end

post '/signup' do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params['password'], password_salt)
  username = params['username']
  user = User.new username: username, email: "meow@meow.se", password: password_hash, salt: password_salt
  user.save
  redirect to('/test')
end

get '*/signup' do
  #@hej = user.created_at
  erb :signup
end

get '*/test' do
  @name = User.all
  erb :test
end

