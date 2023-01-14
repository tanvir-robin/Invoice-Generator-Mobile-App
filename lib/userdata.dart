class UserData {
  String id;
  String name;
  String email;
  String degree;
  String age;
  UserData(this.id, this.name, this.email, this.degree, this.age);

  Map<String, String> toJson() {
    final tmp = {
      'ID': id,
      'Name': name,
      'Email': email,
      'Degree': degree,
      'Age': age
    };
    return tmp;
  }
}
