package api

import (
	"crypto/rand"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"net/http"
	"net/smtp"
	"time"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
)

var db *sql.DB
var temporary_users = make(map[string]string)

func InitDatabase(db_ *sql.DB) {
	db = db_
}

// Для первого этапа регистрации (Ввод почты и подтверждение)
func RegistrationHandler_EmailValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration:")
	w.Header().Set("Content-Type", "application/json")

	var email struct {
		Email string `json:"email"`
	}

	// Try to decode message
	err := json.NewDecoder(r.Body).Decode(&email)
	if err != nil {
		log.Println("Cannot decode request")
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Print Message
	log.Printf("User: %s", email.Email)

	// Check if the mail is valid
	if !database.IsValidEmail(email.Email) {
		log.Printf("Not valid Email")
		http.Error(w, "Not valid Email", http.StatusBadRequest)
		return
	}

	// Check if the mail was used
	if _, exists := temporary_users[email.Email]; exists {
		log.Printf("User already exists")
		http.Error(w, "User already exists", http.StatusConflict)
		return
	}

	if err := database.CheckUser(email.Email, db); err != nil {
		log.Printf("User already exists")
		http.Error(w, "User already exists", http.StatusConflict)
		return
	}

	// Generate number
	number, err := Generate5DigitCode()
	if err != nil {
		log.Printf("Cannot generate code: %s", err)
		http.Error(w, "Cannot generate code", http.StatusInternalServerError)
		return
	}

	// Add user in map
	temporary_users[email.Email] = number

	// Send number to email
	err = sendEmail(email.Email, "Email Validation", number)
	if err != nil {
		log.Printf("Cannot send message: %s", err)
		http.Error(w, "Cannot send verification email", http.StatusInternalServerError)
		return
	}

	// Send successful answer
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Verification code sent",
		"code":    http.StatusOK,
	})
}

func sendEmail(to, subject, body string) error {
	// Настройки SMTP-сервера
	smtpHost := "smtp.gmail.com"
	smtpPort := "587"
	smtpUsername := "projectsmartifyapp@gmail.com"
	smtpPassword := "iegn yhso uqye ikrm"

	// Формируем письмо
	msg := []byte(
		"To: " + to + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"\r\n" +
			body + "\r\n",
	)

	// Аутентификация и отправка
	auth := smtp.PlainAuth("", smtpUsername, smtpPassword, smtpHost)
	err := smtp.SendMail(
		smtpHost+":"+smtpPort,
		auth,
		smtpUsername,
		[]string{to},
		msg,
	)

	return err
}

// Для второго этапа регистрации (Подтверждение кода)
func RegistrationHandler_CodeValidation(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-CodeValidation:")
	w.Header().Set("Content-Type", "application/json")

	type request struct {
		Email string `json:"email"`
		Code  string `json:"code"`
	}
	var user request

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		log.Println("Cannot decode request")
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user.Email]; !exists {
		log.Printf("User does not exists")
		http.Error(w, "User does not exists...", http.StatusBadRequest)
		return
	}

	// Проверяем код
	if user.Code != temporary_users[user.Email] {
		log.Printf("Code does not equal")
		http.Error(w, "Code does not equal...", http.StatusBadRequest)
		return
	}

	// Отправляем успешный ответ
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Code Verified",
		"code":    http.StatusOK,
	})
}

// Для третьего этапа (Создание пароля)
func RegistrationHandler_Password(w http.ResponseWriter, r *http.Request) {
	log.Println("Registration-Password:")
	w.Header().Set("Content-Type", "application/json")

	type request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	var user_request request

	// Декодируем json сообщение
	err := json.NewDecoder(r.Body).Decode(&user_request)
	if err != nil {
		log.Println("Cannot decode request")
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Проверяем сущетсвоание пользователя
	if _, exists := temporary_users[user_request.Email]; !exists {
		log.Printf("User does not exists")
		http.Error(w, "User does not exists...", http.StatusBadRequest)
		return
	}

	var user database.User
	user.Email = user_request.Email
	user.Password_hash = user_request.Password
	user.Created_at = time.Now().Format("2000-01-02 12:00")

	// Добавляем пользователя в базу данных
	err = database.Add_new_user(user, db)
	if err != nil {
		log.Printf("Error with database")
		http.Error(w, "Cannot create user... error with database", http.StatusBadRequest)
		return
	}
	delete(temporary_users, user_request.Email)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Password was created",
		"code":    http.StatusOK,
	})
}

// Функция для генерации 5-значного числа (с ведущими нулями в том числе)
func Generate5DigitCode() (string, error) {
	max := big.NewInt(100000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", fmt.Errorf("Failed to generate random number: %v", err)
	}
	return fmt.Sprintf("%05d", n), nil
}
