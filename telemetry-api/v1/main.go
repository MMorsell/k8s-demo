package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	podName string
	version     = "v1"
	maxLatency  = 1
	errorRate   = 0.5 // 0.5%
	requestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "request_duration_seconds",
			Help:    "Histogram of request durations",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"path", "version", "method", "status_code"},
	)
)


func init() {
	podName = os.Getenv("HOSTNAME")
	prometheus.MustRegister(requestDuration)
}

func getVersion(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	 responseMap := map[string]string{
        "version": version,
        "pod_name": podName,
    }
	response, err := json.Marshal(responseMap)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Simulate a delay between 0 and n seconds
	randomWait := time.Duration(rand.Intn(maxLatency + 1)) * time.Second
	time.Sleep(randomWait)

	// Simulate a 0.5% chance of returning 500 internal server error
	if rand.Float64() < errorRate / 100 {
		fmt.Println("Sending back 500 Internal Server Error to client")
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		recordMetrics(start, r.Method, http.StatusInternalServerError)
		return
	}

	fmt.Println("Sending back 200 OK to client")

	// Write the JSON response to the response writer
	w.Header().Set("Content-Type", "application/json")
	w.Write(response)

	// Record value
	recordMetrics(start, r.Method, http.StatusOK)
}

func recordMetrics(start time.Time, method string, status int) {
	duration := time.Since(start).Seconds()
	labels := []string{"/version", version, method, fmt.Sprint(status)}

	requestDuration.WithLabelValues(labels...).Observe(duration)
}

func healthzHandler(w http.ResponseWriter, r *http.Request) {
    // Perform any necessary health checks here
    // For simplicity, let's just return a 200 OK status
    w.WriteHeader(http.StatusOK)
    fmt.Fprint(w, "OK")
}


func main() {
	// Define a route for handling POST requests to /version
	http.HandleFunc("/version", getVersion)

	// Define handler for prometheus metric scraping
	http.Handle("/metrics", promhttp.Handler())

	http.HandleFunc("/healthz", healthzHandler)

	// Start the HTTP server on port 8080
	http.ListenAndServe(":8080", nil)
}