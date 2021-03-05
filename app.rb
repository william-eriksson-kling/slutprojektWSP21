require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

get('/') do
  slim(:login)
end

post("/login") do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/slutprojekt.db')
  db.results_as_hash = true
  result = db.execute("SELECT * From users WHERE username = ?",username).first
  pwdigest = result["password"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/day')
  else
    "Wrond password"
end

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
  day = params[:dag]
  teamid = params[:team_id].to_i
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("INSERT INTO day VALUES (date,team_id)", day, teamid)
  redirect('/day')
end

post('/todo/new') do
  datum = params[:datum]
  kategori = params[:kategori]
  beskrivning = params[:beskrivning]
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("INSERT INTO to_do VALUES (date,type,description )", datum, kategori, beskrivning)
  redirect('/day')
end