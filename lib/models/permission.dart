class Permissions {
  int? addUser;
  int? addChannel;
  int? all;

  Permissions() {
    addUser = 1 << 1;
    addChannel = 1 << 2;
    all = (1 << 3) - 1;
  }
}
