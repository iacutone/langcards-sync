require 'sinatra'
configure { set :server, :puma }
# require 'pry'
require "sinatra/json"
require 'aescrypt'
require 'dotenv'
Dotenv.load
require 'sinatra/activerecord'
require './translate'
require './user'
require './environments'

# after { ActiveRecord::Base.clear_active_connections }

post '/sign_up' do
  if request.post?
    if params.present? && params[:email].present? && params[:password].present?

      encrypted_password = params['password'].gsub(" ","+").concat("\n")
      decrypted_password = AESCrypt.decrypt(encrypted_password, ENV['AuthPassword'])

      user = User.new(email: params[:email], password: decrypted_password, password_confirmation: decrypted_password)

      if user.save
        json(:status => 200,
             :success => true,
             :id => user.id,
             :email => user.email)
      else
        json(:status => 400,
             :success => false,
             :info => user.errors.full_messages.first) 
      end
    end
  end
end

post '/sign_in' do
  if request.post?
    if params[:email].present? && params[:password].present? 

      user = User.find_by(email: params[:email])

      if user.present?
        encrypted_password = params['password'].gsub(" ","+").concat("\n")
        decrypted_password = AESCrypt.decrypt(encrypted_password, ENV['AuthPassword'])

        if user.authenticate(decrypted_password) == user  
          json(:status => 200,
               :email => user.email,
               :id => user.id)
        else
          json(:status => 400,
               :success => false,
               :info => "Incorrect password")
        end      
      else
        json(:status => 400,
             :success => false,
             :info => "User not found") 
      end
    end
  end
end
