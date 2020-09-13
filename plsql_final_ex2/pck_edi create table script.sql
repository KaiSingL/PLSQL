drop table TM;
create table TM (
   TID varchar2(10) not null,
   TM_TEXT varchar2(100) not null,
   APP_DATE date not null,
   REMARKS varchar2(500),
   STATUS varchar2(1) not null,
constraint TM$PK primary key (TID)
);

drop table TM_OWN;
create table TM_OWN (
   TID varchar2(10) not null,
   REG_ID varchar2(20) not null,
constraint TM_OWN$PK primary key (TID, REG_ID)
);

drop table TM_CAT;
create table TM_CAT (
   TID varchar2(10) not null,
   CAT_ID varchar2(5) not null,
constraint TM_CAT$PK primary key (TID, CAT_ID)
);

drop table CATEGORY;
create table CATEGORY (
   CAT_ID varchar2(5) not null,
   NAME varchar2(50) not null,
constraint CATEGORY$PK primary key (CAT_ID)
);

drop table REG_OWNER;
create table REG_OWNER (
   REG_ID varchar2(20) not null,
   NAME varchar2(100),
constraint REG_OWNER$PK primary key (REG_ID)
);

drop table EDI_QUEUE;
create table EDI_QUEUE (
   QUEUE_ID number(5) not null,
   EDI_STRING varchar2(1000) not null,
constraint EDI_QUEUE$PK primary key (QUEUE_ID)
);

drop table EDI_ERROR;
create table EDI_ERROR (
   QUEUE_ID number(5) not null,
   EDI_STRING varchar2(1000) not null,
   ERR_CODE number(5) not null,
   ERR_DESCRIP varchar2(250) not null,
constraint EDI_ERROR$PK primary key (QUEUE_ID)
);

drop sequence SEQ_TID;
create sequence SEQ_TID START WITH 101;

drop table EDI_OWNER_TEMP;
create table EDI_OWNER_TEMP(
	TM_TEXT varchar2(100) not null,
	REG_ID varchar2(20) not null,
	NAME varchar2(100)
);

drop table EDI_CAT_TEMP;
create table EDI_CAT_TEMP(
	TM_TEXT varchar2(100) not null,
	CAT_ID varchar2(5) not null	
);
