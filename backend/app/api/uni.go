package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

func AddUniversityHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST allowed", http.StatusMethodNotAllowed)
		return
	}

	var data map[string]interface{}
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, "Invalid JSON: "+err.Error(), http.StatusBadRequest)
		return
	}

	err1 := database.AddUniversity(data)
	if err1 != nil {
		http.Error(w, "Database error: "+err1.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "University added"})
}
