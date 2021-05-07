require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
  slim(:"users/login")
  #Ska vara "users/login"
end

get('/users/new') do
  slim(:"users/register")
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  confirm_password = params[:confirm_password]

  username_answer = username.chomp.scan(/\D/).empty?
  
  if username_answer == false
    "Skriv in ett användarnamn"
  end


  if password == confirm_password
    password_correct = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_correct)
    redirect('/login')
  else
    "Lösenord matchar inte"
  end
end

get('/login') do
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
    "Fel lösenord"
end
end



get('/days') do 
    id = session[:id].to_i
    db = SQLite3::Database.new('db/slutprojekt.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM day WHERE user = ?", id)
    # WHERE user = ?,id
    slim(:"days/index",locals:{day:result})
end


get('/days/new') do
  slim(:"days/new")
end

post('/days/new') do
  day = params[:dag]

  if day == nil
    "Skriv in ett datum för ny dag"
  end

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
  datum = db.execute("SELECT date FROM day WHERE id =? ", id).to_s
  todo1 = db.execute("SELECT * FROM to_do WHERE date = ?", datum)
  slim(:"days/show", locals:{todos:todo1})
end