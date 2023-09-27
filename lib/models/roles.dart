class Roles {
  int? baseUser;
  int? modUser;
  int? superUser;

  Roles() {
    baseUser = 1 << 0; //0001
    modUser = (1 << 2) - 1; //0011
    superUser = (1 << 3) - 1; //0111
  }
}
