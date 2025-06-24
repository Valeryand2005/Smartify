package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/api"
)

func main() {
	// register API-route
	http.HandleFunc("/api/login", api.LoginHandler)
	http.HandleFunc("/api/registration_emailvalidation", api.RegistrationHandler_EmailValidation)
	http.HandleFunc("/api/registration_codevalidation", api.RegistrationHandler_CodeValidation)
	http.HandleFunc("/api/registration_password", api.RegistrationHandler_Password)
	http.HandleFunc("/api/forgot_password", api.ForgotPassword)
	http.HandleFunc("/api/reset_password", api.ResetPassword)
	http.HandleFunc("/api/refresh", api.RefreshHandler)

	http.Handle("/reset_password_page/",
		http.StripPrefix("/reset_password_page/",
			http.FileServer(http.Dir("html_pages/reset_password_page"))))

	http.Handle("/success_page/",
		http.StripPrefix("/success_page/",
			http.FileServer(http.Dir("html_pages/success_page"))))

	// Init database
	db, err := sql.Open("postgres", fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	))

	if err != nil {
		log.Printf("Error with database: %s", err)
		return
	}

	api.InitDatabase(db)

	log.Println("Server started on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
