class_name Math

static func modi(number: int, modulus: int):
	if number < 0:
		number = number + modulus

	return number % modulus
