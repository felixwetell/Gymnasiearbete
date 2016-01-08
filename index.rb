require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
#require 'dm-postgres-adapter'
require 'dm-sqlite-adapter'
require 'bcrypt'
require 'sinatra/reloader'


#https://git.heroku.com/stark-earth-2441.git
set :port, 4568

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
#DataMapper.setup(:default, 'postgres://uuzfqirtsdlqch:Qngf4-VL2xom7pTmiBwaZH6L6f@ec2-54-217-240-205.eu-west-1.compute.amazonaws.com/d48tmpto2mh5fi')
set :static, true
set :public_folder, 'public'
set :session_secret, '(S(o5s3t2552qerbw45p03fc055))/MZD'


class User
  include DataMapper::Resource

  property :id            , Serial
  property :username      , String
  property :password      , String, :length => 60
  property :salt          , String, :length => 29

  property :created_at    , DateTime
  property :updated_at    , DateTime
end

class Events
  include DataMapper::Resource

  property :id                , Serial
  property :event_type        , String
  property :event_time_from   , String
  property :event_time_to     , String
  property :event_switch      , String
  property :user              , String
end

class Friends
  include DataMapper::Resource

  property :id            , Serial
  property :user1         , String
  property :user2         , String
end

configure :development do
  DataMapper.auto_upgrade!
  #DataMapper.auto_migrate!
end

DataMapper.finalize

enable :sessions

#Checking if authorized use:
# unless authorized?
#   halt(401, 'Unauthorized')
# end
#For private pages

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

not_found do
  status 404
  erb :error_404
end

get '*/private' do
  unless authorized?
    halt(401, 'Unauthorized')
  end
  begin
    @name = User.get(User.first(username: session[:username]).id).username

  rescue
    erb :error_500
  end
  erb :main_page
end

post '/create_event' do
  Events.create(
      event_type: params['event_type'],
      event_time: params['event_time'],
      user: session[:username]
  )
  redirect to('/private')
end

get '*/login' do
  session[:username] = nil
  erb :login
end

get '*/logout' do
  session[:username] = nil
  halt(200, 'Successfully logged out!')
end

post '/login' do
  begin
    if User.first(username: params['username']) != nil
      id = User.first(username: params['username']).id
      if User.get(id).password == BCrypt::Engine.hash_secret(params['password'], User.get(id).salt)
        session[:username] = User.get(id).username
      end
    else
      halt(401, 'Invalid login')
    end
    redirect to('/private')
  rescue
    erb :error_500
  end
end

post '/signup' do
  begin
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params['password'], password_salt)
    username = params['username']
    user = User.create(
        username: username,
        password: password_hash,
        salt: password_salt
    )
    user.save
    redirect to('/login')
  rescue
    erb :error_500
  end
end

get '*/add_friend_test' do
  erb :add_friend_test
end

post '/add_friend' do
  begin
    if User.first(username: params['add_friend']).username == params['add_friend']
      Friends.create(
          user1: session[:username],
          user2: params['add_friend']
      )
      halt(200, "Successfully added friend! You're not forever alone atm! :D")
    end
  rescue
    erb :error_500
  end
end

post '/events' do
  box_option = ""
  i = 1
  while i < 4
    unless params["box#{i}"] == nil
      box_option = box_option + params["box#{i}"] + " "
    end
    i += 1
  end
  Events.create(
      user: session['username'],
      event_time_from: params['event_time_from'],
      event_time_to: params['event_time_to'],
      event_type: params['event_type'],
      event_switch: box_option
  )
end

get '*/signup' do
  erb :signup
end