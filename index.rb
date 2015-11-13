require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'dm-postgres-adapter'
#require 'dm-sqlite-adapter'
require 'bcrypt'

#https://git.heroku.com/stark-earth-2441.git
set :port, 4568

#DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
DataMapper.setup(:default, 'postgres://uuzfqirtsdlqch:Qngf4-VL2xom7pTmiBwaZH6L6f@ec2-54-217-240-205.eu-west-1.compute.amazonaws.com/d48tmpto2mh5fi')

class User
  include DataMapper::Resource

  property :id       , Serial
  property :username , String
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
    if session[:username] != nil
      if session[:username] == User.get(User.first(username: session[:username]).id).username
        return true
      else
        return false
      end
    end
  else
    return false
  end
end

get '*/private' do
    unless authorized?
        halt(401, 'Unauthorized')
    end
    @name = User.get(User.first(username: session[:username]).id).username
  erb :test
end

get '*/login' do
  erb :login
end

get '*/logout' do
  session[:username] = nil
  halt(200, 'Successfully logged out!')
end

post '/login' do
  if User.first(username: params['username']) != nil
  id = User.first(username: params['username']).id
  if User.get(id).password == BCrypt::Engine.hash_secret(params['password'], User.get(id).salt)
    session[:username] = User.get(id).username
  end
    else halt(401, 'Invalid login')
  end
  redirect to('/private')
end

post '/signup' do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params['password'], password_salt)
  username = params['username']
  user = User.new username: username, password: password_hash, salt: password_salt
  user.save
  redirect to('/login')
end

get '*/signup' do
  erb :signup
end
