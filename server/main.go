package main

import "net/http"
import "log"
import "golang.org/x/net/html"

import "fmt"

func fooHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hello\n")
}

func main() {
	fmt.Println("starting web server")

	// wtf is the difference between handlefunc and handle?? this does not work with handle
	// Diagnostics:
	// compiler: cannot use fooHandler (value of type func(w http.ResponseWriter, r *http.Request)) as http.Handler value in argument to http.Handle: func(w http.ResponseWriter, r *http.Request) does not implement http.Handler (missing method ServeHTTP) [InvalidIfaceAssign]
	// http.Handle("/foo", fooHandler)

	http.HandleFunc("/foo", fooHandler)

	http.HandleFunc("/bar", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
