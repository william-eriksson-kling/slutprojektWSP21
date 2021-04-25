require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
  slim(:"days/index")
  #Ska vara "users/login"
end

get('/users/new') do
  slim(:"users/register")
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  confirm_password = params[:confirm_password]

  if password == confirm_password
    password_correct = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_correct)
    redirect('/showlogin')
  else
    "The password don't match"
  end
end

get('/showlogin') do
  slim(:"users/login")
end

post("/users/login") do
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
    result = db.execute("SELECT * FROM day")
    # WHERE user = ?,id
    slim(:"days/index",locals:{day:result})
end


get('/days/new') do
  slim(:"days/new")
end

post('/days/new') do
  day = params[:dag]
  user_id = session[:id].to_i
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("INSERT INTO day (date,user) VALUES (?,?) ", day, user_id)
  redirect('/days')
end

get('/todos/new') do
  slim(:"todos/new")
end

post('/todos/new') do
  datum = params[:datum]
  kategori = params[:kategori]
  beskrivning = params[:beskrivning]
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.results_as_hash = true
  db.execute("INSERT INTO to_do (date,type,description) VALUES (?,?,?) ", datum, kategori, beskrivning)
  db.execute("INSERT INTO to_do_day (day_id,to_do_id) VALUES (?,?) ", datum, kategori)
  redirect('/days')
end

post('/days/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.execute("DELETE FROM to_do WHERE id = ?",id)
  redirect('/days')
end

get('/days/:id') do
  # Gör så att todos under samma dag visas i en lista
  id = params[:id].to_i
  db = SQLite3::Database.new("db/slutprojekt.db")
  db.results_as_hash = true
  datum1 = db.execute("SELECT date FROM day WHERE id =?", id)
  todos = db.execute("SELECT to_do_id FROM to_do_day WHERE day_id = ?", datum1)
  todo1 = db.execute("SELECT * FROM to_do WHERE type = ?", todos)
  slim(:"days/show", locals:{todos:todo1})
end