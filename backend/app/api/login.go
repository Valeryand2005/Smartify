package api

import (
	"encoding/json"
	"log"
	"net/http"

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
	log.Printf("User: %s, %s", user.Email, user.Password)

	// Connect to database
	db, err := database.ConnectDB("database")

	if err != nil {
		log.Println("Error with database: %s", err)
		http.Error(w, "Error with database... Try again!", http.StatusBadRequest)
		return
	}

	// Add user in database
	err = database.Add_new_user(user, db)

	if err != nil {
		log.Println("Cannot write in database: %s", err)
		http.Error(w, "Error with database... Try again!", http.StatusBadRequest)
		return
	}

	// Generate Token for user
	token := map[string]string{"token": "fake_jwt_token_123"}

	// Send successful answer
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(token)
}
