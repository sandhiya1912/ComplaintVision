bool isEmailValid(String email) {
  // Simple email validation logic
  return email.contains('@');
}

bool isPasswordValid(String password) {
  return password.length >= 6; // Password should be at least 6 characters
}
