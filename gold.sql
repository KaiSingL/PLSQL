declare
	tableName varchar2(100) := 'prime';
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
end;
/
