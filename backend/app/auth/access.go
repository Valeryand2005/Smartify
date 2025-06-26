package auth

import (
	"context"
	"net/http"
)

type contextKey string

const UserIDKey contextKey = "userID"

func Access(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Access_token")
		if authHeader == "" {
			http.Error(w, "Missing or invalid Authorization header", http.StatusUnauthorized)
			return
		}

		//tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		tokenStr := authHeader

		claims, err := ParseToken(tokenStr)
		if claims.Type != "access" {
			http.Error(w, "Invalid token type", http.StatusUnauthorized)
			return
		}
		if err != nil {
			http.Error(w, "Invalid or expired access token", http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
