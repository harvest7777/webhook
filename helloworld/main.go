// oh okay so this first line for any go file probably has to always be the package that thing jawn is part of
package main

// these are just libraries
import "fmt"
import "rsc.io/quote/v4"

func main() {
    fmt.Println("Hello, World!")
    fmt.Println(quote.Go())
		// if i want to use functiosn from the same package, i dotn have to actually import it 
		hello()
}
