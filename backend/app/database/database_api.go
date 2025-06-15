package database

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

type User struct {
	Email    string
	Password string
}

func Add_new_user(user User, database *sql.DB) error {
	log.Printf("Add user to db: %s, %s", user.Email, user.Password)

	database.Exec(
		"CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, email VARCHAR(255) UNIQUE NOT NULL, password VARCHAR(255) NOT NULL );",
	)

	_, err := database.Exec(
		"INSERT INTO users (email, password) VALUES ($1, $2)",
		user.Email,
		user.Password,
	)
	if err != nil {
		return fmt.Errorf("Failed to insert user: %w", err)
	}
	return nil
}
