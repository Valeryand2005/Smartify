package database

import (
	"database/sql"
	"errors"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

type User struct {
	Email    string
	Password string
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

func PrepareUser(email string, database *sql.DB) error {
	err := CreateUsersTable(database)
	if err != nil {
		return fmt.Errorf("Failed to create table: %w", err)
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
	log.Printf("Add user to db: %s, %s", user.Email, user.Password)

	_, err := database.Exec(
		"INSERT INTO users (email, password_hash) VALUES ($1, $2)",
		user.Email,
		HashFunc(user.Password),
	)
	if err != nil {
		return fmt.Errorf("Failed to insert user: %w", err)
	}
	return nil
}
