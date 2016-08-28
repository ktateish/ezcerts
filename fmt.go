package main

import (
	"fmt"
	"bufio"
	"strings"
	"regexp"
	"os"
)

func main() {
	sc := bufio.NewScanner(os.Stdin)
	ws := regexp.MustCompile(`\s+`)
	var entry []string
	for sc.Scan() {
		ts := ws.Split(sc.Text(), -1)
		if ts[0] == "" {
			entry = append(entry, ts[1:]...)
		} else {
			if len(entry) > 0  {
				fmt.Println(entry[0], strings.Join(entry, ","))
				entry = nil
			}
			entry = append(entry, ts...)
		}
	}
	fmt.Println(entry[0], strings.Join(entry, ","))
}
