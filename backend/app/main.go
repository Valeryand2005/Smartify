package main

import (
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api"
)

func main() {
	// Регистрация API-роутов
	http.HandleFunc("/api/login", api.LoginHandler)

	log.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
