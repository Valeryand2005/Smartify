package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var mongoClient *mongo.Client

type University struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Name      string             `bson:"name" json:"name"`
	Country   string             `bson:"country" json:"country"`
	TimeStamp time.Time          `bson:"timestamp" json:"timestamp"`

	ExtraData map[string]interface{} `bson:",extraelements" json:"extra_data,omitempty"`
}

func ConnectMongo(uri string) (*mongo.Client, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}

	log.Println("Successfully connected to MongoDB!")
	mongoClient = client
	return client, nil
}

func CheckConnection(client *mongo.Client) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	err := client.Ping(ctx, nil)
	if err != nil {
		return err
	}

	log.Println("Connected is working now")
	return nil
}

func AddUniversity(data map[string]interface{}) error {
	collection := mongoClient.Database("smartify").Collection("universities")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	uni := University{
		ExtraData: make(map[string]interface{}),
	}
	for key, value := range data {
		switch key {
		case "name":
			if name, ok := value.(string); ok {
				uni.Name = name
			}
		case "country":
			if country, ok := value.(string); ok {
				uni.Country = country
			}
		default:
			uni.ExtraData[key] = value
		}
	}
	if uni.Name == "" || uni.Country == "" {
		return fmt.Errorf("Name or Country are empty")
	}
	data["timestamp"] = time.Now()
	_, err := collection.InsertOne(ctx, data)
	if err != nil {
		return err
	}
	log.Println("Successfully inserted university!")
	return nil
}
