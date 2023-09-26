class Permissions {
  int? addUser;
  int? addChannel;
  int? all;

  Permissions() {
    addUser = 1 << 0;
    addChannel = 1 << 1;
    all = (1 << 2) - 1;
  }
}
