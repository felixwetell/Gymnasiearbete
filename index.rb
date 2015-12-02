require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'dm-postgres-adapter'
# require 'dm-sqlite-adapter'
require 'bcrypt'
# require 'sinatra/reloader'


#https://git.heroku.com/stark-earth-2441.git
set :port, 4568

# DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
DataMapper.setup(:default, 'postgres://uuzfqirtsdlqch:Qngf4-VL2xom7pTmiBwaZH6L6f@ec2-54-217-240-205.eu-west-1.compute.amazonaws.com/d48tmpto2mh5fi')
set :static, true
set :public_folder, 'public'

class User
  include DataMapper::Resource

  property :id       , Serial
  property :username , String
  property :password , String, :length => 60
  property :salt     , String, :length => 29

  property :created_at , DateTime
  property :updated_at , DateTime
end

class Messages
  include DataMapper::Resource

  property :id          , Serial
  property :message     , String
  property :user        , String
end

class Friends
  include DataMapper::Resource

  property :id          , Serial
  property :user1       , String
  property :user2       , String
end

#
# ett table med person 1 och person 2 = friends
# else if p1 = jnkjn and p2 = nil ....

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

####################################

get '*/private' do
    unless authorized?
        halt(401, 'Unauthorized')
    end
    @name = User.get(User.first(username: session[:username]).id).username
    #@time = Messages.all(user: session[:username]).created_at

    @messages = Messages.all(user: session[:username])

    @friend_msg = Messages.all(user: Friends.first(user1: session[:username]).user2)
    p @friend_msg

    @times = [12, 132, 1433, 15554]
  erb :test
end

post '/add_message' do
  Messages.create(message: params['message'], user: session[:username])
  redirect to('/private')
end

#####################################

get '*/login' do
  session[:username] = nil
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



get '*/add_friend_test' do
  erb :add_friend_test
end

post '/add_friend' do
  if User.first(username: params['add_friend']).username == params['add_friend']
     Friends.create(user1: session[:username], user2: params['add_friend'])
  end
  halt(200, "Successfully added friend! You're not forever alone atm! :D")
end



get '*/signup' do
  erb :signup
end


  # dynamic_name = "ClassName"
  # Object.const_set(dynamic_name, Class.new {
  #                                include DataMapper::Resource
  #                                property :id , Serial
  #                                property :friend , String
  #                              })
  #
  # klass = Object.const_set name, Struct.new(*attributes)
  #