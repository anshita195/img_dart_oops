class Permissions {
  int? sendmessage;
  int? addUser;
  int? addChannel;
  int? all;

  Permissions() {
    sendmessage = 1 << 0; //0001
    addUser = 1 << 1; //0010
    addChannel = 1 << 2; //0100
    all = (1 << 3) - 1; //0111
  }
}
