module Model

    def no_username (username)
        if username.empty? == true || username.nil? == true
            "Du har inte skrivit in ett användarnamn"
        else
            redirect('/days')
        end
    end

    def no_day(day)
        if day == nil
            "Skriv in ett datum för ny dag"
        end
    end

    def not_logged_in(id)
        if id == nil
            "Du måste logga in för att använda detta"
            redirect('/login')
        end
    end

    def check_password(pwdigest, password, id)
        if pwdigest == password
            session[:id] = id
            redirect('/days')
        else
            "Fel lösenord/Inte skrivit in ett lösenord"
        end
    end

end