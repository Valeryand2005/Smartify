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

func ConnectDB(databaseName string) (*sql.DB, error) {
	var connStr string = fmt.Sprintf("user=postgres password=ENTER PASSWORD dbname=%s host=localhost port=5432 sslmode=disable", databaseName)
	log.Println(connStr)
	db, err := sql.Open("postgres", connStr)

	// If some error happened
	if err != nil {
		return nil, err
	}
	// Return pointer to database
	return db, nil
}

func Add_new_user(user User, database *sql.DB) error {
	log.Printf("Add user to db: %s, %s", user.Email, user.Password)
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
