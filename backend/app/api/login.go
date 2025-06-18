package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

func LoginHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("New connection!")

	var user database.User
	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&user)

	if err != nil {
		log.Println("Cannot decode request")
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Print Message
	log.Printf("User: %s, %s", user.Email, user.Password_hash)

	// Find user in database
	err = database.FindAndCheckUser(user.Email, user.Password_hash, &user, db)
	if err != nil {
		log.Printf("Cannot write in database: %s", err)
		http.Error(w, "Account will not be found...", http.StatusBadRequest)
		return
	}

	accessToken, refreshToken, err := auth.GenerateTokens(user.ID)
	if err != nil {
		log.Printf("Cannot generate tokens: %s", err)
		http.Error(w, "Error generating tokens", http.StatusInternalServerError)
		return
	}

	err = database.StoreRefreshToken(user.ID, refreshToken, db)
	if err != nil {
		log.Printf("Cannot store refresh token: %s", err)
		http.Error(w, "Error saving refresh token", http.StatusInternalServerError)
		return
	}

	resp := map[string]string{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}

	// Send successful answer
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
