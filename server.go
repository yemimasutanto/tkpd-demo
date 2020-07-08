package main

import (
  "net/http"
  "os"
  "io/ioutil"
  "log"
  
  "github.com/labstack/echo"
  "github.com/labstack/echo/middleware"
)

func main() {
  // Echo instance
  e := echo.New()

  // Middleware
  e.Use(middleware.Logger())
  e.Use(middleware.Recover())

  // Routes
  e.GET("/", hello)
  e.GET("/server-up", server)
  e.GET("/ping", ping)

  // Start serve
  e.Logger.Fatal(e.Start("0.0.0.0:1323"))
}

// Handler
func hello(c echo.Context) error {
  return c.String(http.StatusOK, "Hello, World!")
}

func ping(c echo.Context) error {
  return c.String(http.StatusOK, "pong!")
}

func server(c echo.Context) error {
  file, err := os.Open("service_wake_date.txt")

  if err != nil {
    log.Fatal(err)
  }
  defer file.Close()

  datefile, err := ioutil.ReadAll(file)
  msg := "server up: " + string(datefile)
  return c.String(http.StatusOK, msg)
}

