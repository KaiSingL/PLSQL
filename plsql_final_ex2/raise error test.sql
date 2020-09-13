declare
	invalid_reg_id exception;
	pragma exception_init (invalid_reg_id,-20100);
	invalid_cat exception;
	pragma exception_init(invalid_cat, -20200);
	invalid_apt exception;
	pragma exception_init(invalid_apt, -20300);
	invalid_tm_mod exception;
	pragma exception_init(invalid_tm_mod, -20400);
begin
	raise_application_error(-20100,'Invalid Registrtion ID');
	raise_application_error(-20200,'Invalid Categroy ID');
	raise_application_error(-20300,'Application Date must be whithin the current year');
	raise_application_error(-20400,'Trade mark can no longer be modified');
	exception
		when others then dbms_output.put_line(sqlcode||' - '||sqlerrm);
end;
/