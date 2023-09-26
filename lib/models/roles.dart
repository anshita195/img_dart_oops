class Roles {
  int? baseUser;
  int? modUser;
  int? superUser;

  Roles() {
    baseUser = 1;
    modUser = 1 << 0;
    superUser = (1 << 2) - 1;
  }
}
