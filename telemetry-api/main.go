package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// who am I

// prometheus???

// robinhood - follow the usage patternj
// antagning.se - vem vill stå i en sunkig kö
// exercise 2?

func main() {
	app := fiber.New()

	ctx := context.Background()

	// Connect to the MongoDB service
	connectCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(connectCtx, options.Client().ApplyURI("mongodb://localhost:27017"))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)

	// Create a collection handle
	db := client.Database("mydb")
	_ = db.Collection("mycollection")

	// Define API route
	app.Get("/", func(c *fiber.Ctx) error {
		// Insert a sample document
		return c.SendString("Data inserted by successfully!")

		// doc := bson.M{"name": "John Doe", "age": 30}
		// _, err := collection.InsertOne(ctx, doc)
		// if err != nil {
		// 	log.Println("Error inserting document:", err)
		// 	return c.Status(http.StatusInternalServerError).SendString("Error inserting document")
		// }
	})

	// Start the server
	port := 8080
	log.Printf("Server listening on port %d...", port)
	log.Fatal(app.Listen(fmt.Sprintf(":%d", port)))
}
