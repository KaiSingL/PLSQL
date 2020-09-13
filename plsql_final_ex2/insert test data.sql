insert into category values ('CAT01','ANIME');
INSERT INTO CATEGORY VALUES ('CAT02','MOVIE');
INSERT INTO REG_OWNER VALUES ('R001','VALI');
INSERT INTO REG_OWNER VALUES ('R002','TOM');
insert into edi_queue values (seq_tid.nextval, 'UNB+UNOA''TXT+Orange''ADT+20200628''REMARKS+Good Movie''OWN+R001''CAT+CAT01''UNZ+1');
insert into edi_queue values (seq_tid.nextval,'UNB+UNOA''TXT+Pear''ADT+20200920''REMARKS+Very Good Movie''OWN+R002''CAT+CAT02''UNZ+1');
insert into edi_queue values (seq_tid.nextval,'UNB+UNOA''TXT+Grapes''ADT+20200920''REMARKS+Very Good Movie''OWN+R001''CAT+CAT03''UNZ+1');
insert into edi_queue values (seq_tid.nextval,'UNB+UNOA''TXT+pie''ADT+20200920''REMARKS+Very Good Movie''OWN+R001''CAT+CAT01''UNZ+1');
insert into edi_queue values (seq_tid.nextval, 'UNB+UNOA''TXT+apple''ADT+20200920''REMARKS+Nice Movie''OWN+R001:Leon''CAT+CAT02''UNZ+1' );

-- create one with status = 'N'
insert into edi_queue values (seq_tid.nextval, 'UNB+UNOA''TID+TM0106''TXT+Orange''ADT+20200628''REMARKS+Good FOR FAMILY''OWN+R001:LEON"OWN+R002''CAT+CAT01''CAT+CAT02''UNZ+1');
-- create one with status = 'C'
insert into edi_queue values (seq_tid.nextval,'UNB+UNOA''TID+TM0107''TXT+Pear''ADT+20200920''REMARKS+Very Good Movie''OWN+R002''CAT+CAT02''UNZ+1');