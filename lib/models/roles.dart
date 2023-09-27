class Roles {
  int? baseUsercat;
  int? modUsercat;
  int? superUsercat;
  int? baseUser;
  int? modUser;
  int? superUser;

  Roles() {
    baseUsercat = 1 << 0; //0001
    modUsercat = 1 << 1; //0010
    superUsercat = 1 << 2; //0100

    baseUser = 1 << 0; //0001
    modUser = (1 << 2) - 1; //0011
    superUser = (1 << 3) - 1; //0111
  }
}
