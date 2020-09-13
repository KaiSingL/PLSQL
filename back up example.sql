create or replace package pck_backup_data as
  procedure genBackupData(tableName varchar2);
  procedure restoreData( tableName varchar2);
end pck_backup_data;
/

create or replace package body pck_backup_data as
  procedure genBackupData(tableName varchar2)
  as
	script varchar2(2000);
	script_pos number := 1;
	cursor tab is select column_name, data_type from user_tab_cols where table_name = upper(tableName);
	/* ofile UTL_FILE.FILE_TYPE; */
begin
	script := '
	begin
	for rec in ( select * from '||upper(tableName) ||') loop
	insert into ins_stmt values ('''||upper(tableName)||''',''insert into prime values (''';
	for col in tab loop
		case col.data_type
		when 'NUMBER' then 
			script := script||'||rec.'||col.column_name||'||'',''';
		else 
			script := script||'''''||rec.'||col.column_name||'||'''''',''';
		end case;
	end loop;
	script := substr(script,1,length(script)-2);
	script := script||')'');
	end loop;
	end;';
	/* while script_pos < length(script) loop
		dbms_output.put_line(substr(script,script_pos,250));
		script_pos := script_pos +250;
		end loop; */
	execute immediate script;
	/* ofile := utl_file.fopen('C:\Users\leonlau\Documents\PLSQL','script.sql','W');
	utl_file.put_line(ofile,script);
	utl_file.fclose(ofile); */
end genbackupdata;

  procedure restoreData( tableName varchar2)
  as
  cursor cs is select * from ins_stmt where table_name = upper(tableName);
  chec ins_stmt%rowtype;
  begin
	savepoint s1;
	--execute immediate 'truncate table '||tableName;
	open cs;
	fetch cs into chec;
	if cs%notfound then 
		dbms_output.put_line('no data is found');
		end if;
	close cs;
    for rec in cs loop
		execute immediate rec.ins_sql;
    end loop;
	delete ins_stmt where table_name = upper(tableName);
	exception 
		when others then 
			rollback to s1;
			dbms_output.put_line('process terminated, rollback completed');
	end restoreData;
 end pck_backup_data;
/

