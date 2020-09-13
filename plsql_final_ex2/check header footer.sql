create or replace
function checkHF(str varchar2) return boolean
is 
begin
	if substr(str,1,9) = 'UNB+UNOA''' and substr(str,length(str)-5,length(str)) = '''UNZ+1'then
		dbms_output.put_line('EDI format header and footer tags found');
		return true;
	else
		dbms_output.put_line('String not follows EDI format' );
		return false;
	end if;
end checkHF;
/