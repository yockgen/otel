package main

//Factoria
func Factoria(n int) (int, error) {

	if n <= 1 {
		return 0, nil
	}

	var result int = 1
	for i :=1; i <= n; i++ {
		result = result * i
	}
	return result,nil

}
