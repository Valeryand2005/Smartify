package api

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/IU-Capstone-Project-2025/Smartify/backend/app/database"
	"github.com/google/uuid"
)

const DOMAIN = "localhost"
const PORT = "22025"

var recovery_users = make(map[string]string)

func ForgotPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request struct {
		Email string `json:"email"`
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
		return
	}

	// Проверка на существование пользователя в базе данных
	err = database.CheckUser(request.Email, db)
	if err != database.ErrDuplicateUser {
		log.Println("User not found or other errors")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User not found or other errors",
		})
		return
	}

	// Генерируем токен
	token := uuid.New().String()

	// Создаем ссылку для востановления пароля
	resetLink := "http://" + DOMAIN + ":" + PORT + "/reset_password_page?token=" + token

	// Добавляем токен и почту в список пользователей на восстановление
	recovery_users[token] = request.Email

	// Отправляем письмо
	err = sendEmail(request.Email, "Recovery password", "Click to link to reset password: "+resetLink)
	if err != nil {
		log.Println("Cant send mail")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cant send mail",
		})
		return
	}

	// Ответ об успехе
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"message": "Password reset link sent to your email"})
	return
}

func ResetPassword(w http.ResponseWriter, r *http.Request) {
	log.Println("Request to recovery password!")
	w.Header().Set("Content-Type", "application/json")

	var request struct {
		Token       string `json:"token"`
		NewPassword string `json:"newPassword"`
	}

	// Расшифровываем сообщение
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Println("Cannot decode request")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Invalid JSON",
		})
	}

	// Ищем пользователя по токену
	email := recovery_users[request.Token]
	if email == "" {
		log.Println("User not found")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "User not found",
		})
	}

	// Обновляем пароль в базе данных
	err = database.UpdateUsersPassword(email, request.NewPassword, db)
	if err != nil {
		log.Println("Cannot update password")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Cannot update password",
		})
	}

	// Удаляем использованный токен
	delete(recovery_users, request.Token)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"type": "OK",
	})
}
