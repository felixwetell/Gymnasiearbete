require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
# require 'dm-postgres-adapter'
require 'dm-sqlite-adapter'
require 'bcrypt'
require 'sinatra/reloader'

set :port, 4568

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
# DataMapper.setup(:default, 'postgres://uuzfqirtsdlqch:Qngf4-VL2xom7pTmiBwaZH6L6f@ec2-54-217-240-205.eu-west-1.compute.amazonaws.com/d48tmpto2mh5fi')
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
  property :event_type        , Text
  property :event_location    , Text
  property :event_date        , String
  property :event_time_from   , String
  property :event_time_to     , String
  property :event_time_change , String
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
   # DataMapper.auto_migrate!
end

DataMapper.finalize

enable :sessions

# Function that is used to check if a user is authenticated.
# Add code below to get method when getting protected pages:
# unless authorized?
#   halt(401, 'Unauthorized')
# end

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

get '*/main_page' do
  unless authorized?
    halt(401, 'Unauthorized')
  end

  begin
    @name = session[:username]
    events = []
    friends_query = Friends.all(user1: @name)
    friends_query.each do |friend|
      events << Events.all(user: friend.user2)
    end

    events = events.flatten!
    # Putting all usernames from the events into
    # @usernames_from_events for page display

    @usernames_from_events = []
    @event_types_from_events = []
    @event_locations_from_events = []
    @event_times_from_from_events = []
    @event_times_to_from_events = []
    @event_time_changes_from_events = []
    @event_date_from_events = []

    events.each do |event|
      @usernames_from_events << event.user
      @event_types_from_events << event.event_type
      @event_locations_from_events << event.event_location
      @event_date_from_events << event.event_date
      @event_times_from_from_events << event.event_time_from
      @event_times_to_from_events << event.event_time_to
      @event_time_changes_from_events << event.event_time_change
    end
  rescue
    erb :error_500
  end
  erb :main_page
end

get '*/TOS' do
  begin
    erb :TOS
  rescue
    erb :error_500
  end
end

get '*/tos' do
  begin
    erb :TOS
  rescue
    erb :error_500
  end
end

# Taking all the users friends from the database
# and putting them in a array (@friends) that can
# be displayed on the page.

get '*/friends' do
  unless authorized?
    halt(401, 'Unauthorized')
  end
  begin
    @name = session[:username]
    @friends = []
    friends_query = Friends.all(user1: @name)
    friends_query.each do |friend|
      @friends << friend.user2
    end
  rescue
    erb :error_500
  end
  erb :friends
end

# When adding a friend, the users username
# and the friend username will be sent to the database.

post '/add_friend' do
  begin
    if User.first(username: params['add_friend']).username == params['add_friend']
      @name = session[:username]
      @friends = []
      friends_query = Friends.all(user1: @name)
      friends_query.each do |friend|
        @friends << friend.user2
      end
      if @friends.include?(params['add_friend'])
        halt(400, "You are already following #{params['add_friend']}. You can't 'SuperStalk' someone")
      else
        Friends.create(
          user1: session[:username],
          user2: params['add_friend']
      )
      halt(200, "Successfully added friend! You're not forever alone atm! :D")
      end
    end
  rescue
    erb :error_500
  end
end

# Sending the information gathered when user creates
# an event to the database.

post '/create_event' do
  begin
  if params['event_type'] == 'Other'
    event_type = params['specify_other_event']
  else
    event_type = params['event_type']
  end
  if params['event_location'] == 'Other'
    event_location = params['specify_other_location']
  else
    event_location = params['event_location']
  end
  Events.create(
      event_type: event_type,
      event_date: params['event_date'],
      event_time_from: params['event_time_from'],
      event_time_to: params['event_time_to'],
      event_location: event_location,
      event_time_change: params['event_time_change'],
      user: session[:username]
  )
  redirect to('/main_page')
  rescue
    erb :error_500
  end
end

get '*/login' do
  session.clear
  erb :login
end

get '*/logout' do
  session.clear
  halt(200, 'Successfully logged out!')
end

# Checkign if the encrypted password is valid.
# Generating a new password hash using the input password
# and the old password salt and comparing the new hash with the old one
# if new hash == old hash: Authenticated!

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
    redirect to('/main_page')
  rescue
    erb :error_500
  end
end

# Using Bcrypt to encrypt the passwords
# and send them to the database.

post '/signup' do
  begin
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params['password'], password_salt)
    username = params['username']
    if User.first(username: username) == nil
    user = User.create(
        username: username,
        password: password_hash,
        salt: password_salt
    )
    user.save
    else
      halt(409, 'Username already exists.')
    end
    redirect to('/login')
  rescue
    erb :error_500
  end
end

get '*/about' do
  erb :about
end
