package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "Hello from Gin + Istio 🚀",
		})
	})

	r.Run(":8080") // listen and serve on port 8080
}
