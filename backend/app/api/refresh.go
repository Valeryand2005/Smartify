package api

import (
	"encoding/json"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/auth"
	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

func RefreshHandler(w http.ResponseWriter, r *http.Request) {
	var req RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	claims, err := auth.ParseToken(req.RefreshToken)
	if err != nil {
		http.Error(w, "Invalid refresh token", http.StatusUnauthorized)
		return
	}

	valid, userID, err := database.IsRefreshTokenValid(req.RefreshToken, db)
	if err != nil || !valid || claims.UserID != userID {
		http.Error(w, "Refresh token expired or invalid", http.StatusUnauthorized)
		return
	}

	_ = database.DeleteRefreshToken(req.RefreshToken, db)

	accessToken, newRefreshToken, err := auth.GenerateTokens(userID)
	if err != nil {
		http.Error(w, "Could not generate tokens", http.StatusInternalServerError)
		return
	}

	_ = database.StoreRefreshToken(userID, newRefreshToken, db)

	json.NewEncoder(w).Encode(TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	})
}
