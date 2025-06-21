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
	w.Header().Set("Content-Type", "application/json")

	var req RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid request",
		})
		return
	}

	claims, err := auth.ParseToken(req.RefreshToken)
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid refresh token",
		})
		return
	}

	valid, userID, err := database.IsRefreshTokenValid(req.RefreshToken, db)
	if err != nil || !valid || claims.UserID != userID {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Refresh token expired or invalid",
		})
		return
	}

	database.DeleteRefreshToken(req.RefreshToken, db)

	accessToken, newRefreshToken, err := auth.GenerateTokens(userID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Could not generate tokens",
		})
		return
	}

	database.StoreRefreshToken(userID, newRefreshToken, db)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(TokenResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	})

	return
}
