require './index'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'
require 'bcrypt'
require 'dm-sqlite-adapter'
run Sinatra::Application
