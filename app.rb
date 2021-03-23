require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

get('/') do
  slim(:"days/index")
  #SKa vara "users/login"
end

post('/users/new')
  username = params[:username]
  password = params[:password]
  confirm_password = params[:confirm_password]

  if password == confirm_password
    password_correct = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_correct)
    redirect('/login')
  else
    "The password don't match"
  end
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
    redirect('/days')
  else
    "Wrong password"
end
end

get('/days') do 
    id = session[:id].to_i
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM to_do WHERE id = ?",id)
    slim(:"days/index", locals:{todos:result})
end

get('/days/new') do
  slim(:"days/new")
end

post('/days/new') do
  day = params[:dag]
  teamid = params[:team_id].to_i
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("INSERT INTO day VALUES (date,team_id)", day, teamid)
  redirect('/days')
end

post('/todos/new') do
  datum = params[:datum]
  kategori = params[:kategori]
  beskrivning = params[:beskrivning]
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("INSERT INTO to_do VALUES (date,type,description )", datum, kategori, beskrivning)
  redirect('/days')
end






get('/days/:id') do
  # Gör så att todos under samma dag visas i en lista
  id = params[:id].to_i
  db = SQLite3::Database.new("db/chinook-crud.db")
  db.results_as_hash = true
  slim(:"days/show")
end