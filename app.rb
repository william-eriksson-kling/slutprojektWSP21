require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

get('/day') do 
    id = session[:id].to_i
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM todos WHERE user_id = ?",id)
    slim(:"day/index", locals:{todos:result})
  end

  get('/day/new') do
    slim(:"day/new")
  end

  post('/day/new') do
    title = params[:]
    artist_id = params[:].to_i
    db = SQLite3::Database.new("db/slutprojekt.db")
    db.execute("INSERT INTO - VALUES (?,?)",)
    redirect('/day')
  end