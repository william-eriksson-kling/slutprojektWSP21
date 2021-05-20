
module Model
    #def no_username(username)
        #if username == ""
            #return "Skriv in ett användarnamn"
        #end
    #end

    def no_day(day)
        if day == nil
            return "Skriv in ett datum för ny dag"
        end
    end

    #def not_logged_in(id)
        #if id == nil
            #return "Du måste logga in för att använda detta"
        #end
    #end

    def check_password(pwdigest, password, id)
        if pwdigest == password
            session[:id] = id
            redirect('/days')
        else
            return "Fel lösenord/Inte skrivit in ett lösenord"
        end
    end

    def confirm_password(password, confirm_password, username)
        if password == confirm_password
            password_correct = BCrypt::Password.create(password)
            db = SQLite3::Database.new('db/slutprojekt.db')
            db.execute("INSERT INTO users (username,password) VALUES (?,?)",username,password_correct)
            redirect('/login')
        else
            "Lösenord matchar inte"
        end
    end
    
end
