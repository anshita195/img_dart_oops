class Roles {
  int? baseUser;
  int? modUser;
  int? superUser;

  Roles() {
    baseUser = 1 << 0;
    modUser = 1 << 1;
    superUser = (1 << 3) - 1;
  }
}
