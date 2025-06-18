package database

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"regexp"

	_ "github.com/lib/pq"
)

type User struct {
	id            int
	Email         string `json:"email"`
	Password_hash string `json:"password"`
	First_name    sql.NullString
	Last_name     sql.NullString
	Middle_name   sql.NullString
	Date_of_birth sql.NullString
	Created_at    string
	Last_login    sql.NullString
	Is_active     bool
	User_role     string
}

var (
	ErrUserNotFound  = errors.New("database: user not found")
	ErrDuplicateUser = errors.New("database: user with such email already exists")
)

func CreateUsersTable(database *sql.DB) error {
	_, err := database.Exec(
		`CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    middle_name VARCHAR(100),
    date_of_birth DATE CHECK (date_of_birth > '1900-01-01'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    user_role VARCHAR(20) NOT NULL DEFAULT 'student' 
        CHECK (user_role IN ('student', 'tutor', 'administrator')));`,
	)
	return err
}

func IsValidEmail(email string) bool {
	regex := `^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$`
	re := regexp.MustCompile(regex)
	return re.MatchString(email)
}

func CheckUser(email string, database *sql.DB) error {
	var id int
	err := database.QueryRow("SELECT id FROM users WHERE email = $1", email).Scan(&id)
	if err == sql.ErrNoRows {
		return nil
	}
	if err != nil {
		return fmt.Errorf("Failed to check email: %w", err)
	}
	return ErrDuplicateUser
}

// Функция для получшения данных о пользователе
func FindUser(email string, password string, user *User, database *sql.DB) error {
	err := database.QueryRow(`
        SELECT id, email, password_hash, first_name, last_name, middle_name, 
               date_of_birth, created_at, last_login, is_active, user_role
        FROM users 
        WHERE email = $1 and password_hash = $2`, email, password).Scan(
		&user.id,
		&user.Email,
		&user.Password_hash,
		&user.First_name,
		&user.Last_name,
		&user.Middle_name,
		&user.Date_of_birth,
		&user.Created_at,
		&user.Last_login,
		&user.Is_active,
		&user.User_role,
	)

	if err == sql.ErrNoRows {
		return ErrUserNotFound
	}
	if err != nil {
		return fmt.Errorf("Failed to query user: %w", err)
	}
	return nil
}

func PrepareUser(email string, database *sql.DB) error {
	err := CreateUsersTable(database)
	if err != nil {
		return fmt.Errorf("Failed to create table: %w", err)
	}
	if !IsValidEmail(email) {
		return fmt.Errorf("invalid email format")
	}
	err2 := CheckUser(email, database)
	if err2 != nil {
		return err2
	}
	return nil
}

func HashFunc(s string) string {
	return s
}

func Add_new_user(user User, database *sql.DB) error {
	log.Printf("Add user to db: %s, %s", user.Email, user.Password_hash)

	_, err := database.Exec(
		"INSERT INTO users (email, password_hash) VALUES ($1, $2)",
		user.Email,
		HashFunc(user.Password_hash),
	)
	if err != nil {
		return fmt.Errorf("Failed to insert user: %w", err)
	}
	return nil
}
