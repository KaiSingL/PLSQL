drop table SYS_USR;
create table SYS_USR (
   USER_ID varchar2(15) not null,
   PASSWORD varchar2(15) not null,
   NAME varchar2(50) not null,
   EXPIRY_DATE date,
   ACTIVE varchar2(1) not null,
   LOGIN_FAIL number(1),
   SUPERUSER varchar2(1) not null,
constraint SYS_USR$PK primary key (USER_ID)
);

drop table ROLE;
create table ROLE (
   ROLE_ID varchar2(15) not null,
   DESCRIP varchar2(30) not null,
   ACTIVE varchar2(1) not null,
   LSTUPDUSR varchar2(15) not null,
   LSTUPDDT date not null,
constraint ROLE$PK primary key (ROLE_ID)
);

drop table ROLE_FUNC;
create table ROLE_FUNC (
   ROLE_ID varchar2(15) not null,
   FUNC_ID varchar2(15) not null,
   READ varchar2(1) not null,
   INS varchar2(1) not null,
   UPD varchar2(1) not null,
   DEL varchar2(1) not null,
   EXE varchar2(1) not null,
constraint ROLE_FUNC$PK primary key (ROLE_ID, FUNC_ID)
);

drop table ROLE_MEM;
create table ROLE_MEM (
   ROLE_ID varchar2(15) not null,
   USER_ID varchar2(15) not null,
constraint ROLE_MEM$PK primary key (ROLE_ID, USER_ID)
);
