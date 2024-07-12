import 'package:bcrypt/bcrypt.dart';

void main() {
  // Replace with the plaintext password you want to hash
  String plaintextPassword = 'mysecretpassword';

  // Hash the plaintext password using bcrypt
  String hashedPassword = BCrypt.hashpw(plaintextPassword, BCrypt.gensalt());

  // Print the hashed password to the console
  print('Hashed Password: $hashedPassword');
}
