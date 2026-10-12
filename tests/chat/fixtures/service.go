package service

// Fetch returns the account. It delves into the cache first.
//
//	acct := Fetch("id") // Oops! example code is left alone
func Fetch(id string) Account {
	msg := "// Oops! not a comment"
	return Account{} // now uses the default account
}
