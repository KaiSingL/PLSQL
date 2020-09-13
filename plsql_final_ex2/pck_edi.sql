create or replace package pck_edi 
as
	procedure processAll;
end pck_edi;
/

create or replace package body pck_edi 
as

	procedure get_pos(plus_pos in out number, quote_pos in out number , edi varchar2) -- checked
	is 
	begin
		plus_pos := instr(edi,'+');
		quote_pos := instr(edi,'''');
		--dbms_output.put_line(plus_pos);
		--dbms_output.put_line(quote_pos);
	end get_pos;
	
	procedure split_tag_content(tag in out varchar2, content in out varchar2, edi varchar2, plus_pos number ,quote_pos number) -- checked
	is 
	begin
		tag := substr(edi,1,plus_pos-1);
		content := substr(edi,plus_pos+1,quote_pos-1-plus_pos);
		-- dbms_output.put_line(tag);
		-- dbms_output.put_line(content);
	end split_tag_content;
	
	function get_tid return varchar2 -- checked
	is 
	txt varchar2(10);
	begin
		txt :=  'TM'||lpad(SEQ_TID.nextval,4,0);
		--dbms_output.put_line(txt);
		return txt;
	end get_tid;
	
	function checkHF(str varchar2) return boolean -- checked
	is 
	begin
		if substr(str,1,9) = 'UNB+UNOA''' and substr(str,length(str)-5,length(str)) = '''UNZ+1'then
			--dbms_output.put_line('EDI format header and footer tags found');
			return true;
		else
			dbms_output.put_line('String not follows EDI format' );
			return false;
		end if;
	end checkHF;
	
	function checkDT(adt date) return boolean -- checked
	is 
	begin
		if extract(year from adt) >= extract(year from sysdate) then 
			dbms_output.put_line('the date : '||adt||' is within range');
			return true;
		else 
			dbms_output.put_line('the date : '||adt||' is out of range');
			return false;
		end if;
	end checkDT;
	
	function checkOwner(id varchar2) return boolean -- checked
	is 
		owner reg_owner%rowtype;
	begin
		select * into owner from reg_owner where reg_ID = id;
		dbms_output.put_line ('Owner '||owner.name ||' is valid');
		return true;
	exception
		when no_data_found then 
			dbms_output.put_line('No ID is found');
			return false;
	end checkOwner;
	
	function checkCat(id varchar2) return boolean -- checked
	is 
		cat category%rowtype;
	begin
		select * into cat from category where cat_id = id;
		dbms_output.put_line ('Category '||cat.name ||' is valid');
		return true;
	exception
		when no_data_found then 
			dbms_output.put_line('CAT_ID: '||ID||' is NOT found');
			return false;
	end checkCat;
	
	function check_tm_status(id varchar2) return boolean
	is -- checked
		tmdata tm%rowtype;
	begin
		select * into tmdata from tm where tid = id;
		if tmdata.status = 'N' then
			dbms_output.put_line('Trade Mark status is New');
			return true;
		else
			dbms_output.put_line('Trade Mark status not new, status : '||tmdata.status);
			return false;
		end if;
		exception
			when no_data_found then 
				dbms_output.put_line('No data is found in check_tm_status');
	end check_tm_status;
	
		procedure edi_split(edi in out varchar2, tid in out varchar2, ttxt in out varchar2, adt in out date, rmks in out varchar2)  -- checked
	is 
		plus_pos number; -- position of the first '='
		quote_pos number; -- position of the first ' ' ' 
		tag varchar2(100); -- decoded tag
		content varchar2(100); -- decoded content
		owner_name varchar2(100); -- owner's optional name 
		invalid_edi_format exception;
		pragma exception_init(invalid_edi_format,-20500);
	begin
		while length(edi) >0 loop
				get_pos(plus_pos, quote_pos, edi);
				split_tag_content(tag, content, edi, plus_pos,quote_pos);
				--dbms_output.put_line('tag: '||tag);
				--dbms_output.put_line('content: '||content);
				case tag
					when 'TID' THEN 
						tid := content;
					WHEN 'TXT' THEN
						ttxt := content;
					WHEN 'ADT' THEN
						adt := to_date(content, 'YYYYMMDD');
					when 'REMARKS' then
						rmks := content;
					WHEN 'OWN' THEN						
						if instr(content,':') <> 0 then 
							owner_name := substr(content, instr(content,':')+1);
							content := substr(content, 1, instr(content,':')-1);
							insert into edi_owner_temp values (ttxt, content, owner_name);
						else
						insert into edi_owner_temp values (ttxt, content, owner_name);
						end if;
						owner_name := '';
					WHEN 'CAT' THEN
							insert into edi_cat_temp values (ttxt, content);		
					else 
						dbms_output.put_line('EDI format error');
						raise_application_error(-20500,'Invalid edi fomat');
				end case;
				edi := substr(edi, quote_pos+1);
				--dbms_output.put_line('new edi: '||edi);
			end loop;
			dbms_output.put_line('TID: '||tid);
			dbms_output.put_line('TITLE: '||ttxt);
			--dbms_output.put_line('adt: '||adt);
			--dbms_output.put_line('rmks: '||rmks);
	end edi_split;
	
	procedure create_tm(tid varchar2, ttxt varchar2, adt date, rmks varchar2)
	is -- checked
	begin
		insert into tm values (tid, ttxt, adt, rmks, 'N');
	end create_tm;
	
	procedure process_owner(tid varchar2, ttxt varchar2)
	is -- checked
		invalid_reg_id exception;
		pragma exception_init (invalid_reg_id,-20100);
		cursor cs is select * from edi_owner_temp where tm_text = ttxt;
		reg reg_owner%rowtype;
		temp edi_owner_temp%rowtype;
	begin
			for temp_own in cs loop
				if checkOwner(temp_own.reg_ID) then
					if reg.name <> temp_own.name then
						select * into reg from reg_owner where reg_ID = temp_own.reg_ID;
						update reg_owner set name = temp_own.name where reg_ID = temp_own.reg_ID;
						dbms_output.put_line('Owner''s name is updated to '||temp_own.name);
					end if;
					insert into tm_own values (tid, temp_own.reg_ID);
					dbms_output.put_line('1 row inserted to TM_OWN');
				else 
					raise_application_error(-20100,'Invalid Registration ID');
				end if;
			end loop;
			open cs;
			if cs%notfound then
				dbms_output.put_line('Error - No row is fetched from EDI_OWNER_TEMP');
			end if;
			close cs;
	end process_owner;
	
	procedure process_cat(tid varchar2, ttxt varchar2)
	is  -- checked
		invalid_cat exception;
		pragma exception_init(invalid_cat, -20200);
		cursor cs is select * from edi_cat_temp where tm_text = ttxt;
		temp edi_cat_temp%rowtype;
	begin
		for temp_cat in cs loop
			if checkCat(temp_cat.cat_id) then
				insert into tm_cat values (tid, temp_cat.cat_id);
				dbms_output.put_line('one row is inserted to TM_CAT');
			else raise_application_error(-20200,'Invalid Category ID');
			end if;
		end loop;
		open cs;
		fetch cs into temp;
		if cs%notfound then 
			dbms_output.put_line('Error - No row is fetched from cat_TEMP');
		end if;
		close cs;
	end process_cat;
	
	procedure update_tm(id varchar2,ttxt varchar2,rmks varchar2) 
	is  -- checked
	begin
		update tm set tm_text = ttxt, remarks = rmks where tid = id;
		dbms_output.put_line('row of TM where TID = '||id||' is updated');
	end update_tm;
	
	procedure update_owner(id varchar2,ttxt varchar2)
	is -- checked with edi_read
		invalid_reg_id exception;
		pragma exception_init (invalid_reg_id,-20100);
		cursor cs is select * from edi_owner_temp where tm_text = ttxt;
		reg reg_owner%rowtype;
		temp edi_owner_temp%rowtype;
	begin
		delete from tm_own where tid = id;
		for temp_own in cs loop 
			if checkOwner(temp_own.reg_ID) then
				select * into reg from reg_owner where reg_ID = temp_own.reg_ID;
				if reg.name <> temp_own.name then
					update reg_owner set name = temp_own.name where reg_ID = temp_own.reg_ID;
					dbms_output.put_line('Owner''s name is updated to '||temp_own.name);
				end if;
				insert into tm_own values (id, temp_own.reg_ID);
				dbms_output.put_line('1 row inserted to TM_OWN');				
			else 
				raise_application_error(-20100,'Invalid Registration ID');
			end if;
		end loop;
		open cs;
		if cs%notfound then
			dbms_output.put_line('Error - No row is fetched from EDI_OWNER_TEMP');
		end if;
		close cs;
	end update_owner;
	
	procedure update_cat(id varchar2,ttxt varchar2)
	is -- checked with edi_read
		invalid_cat exception;
		pragma exception_init(invalid_cat, -20200);
		cursor cs is select * from edi_cat_temp where tm_text = ttxt;
		temp edi_cat_temp%rowtype;
	begin
		delete from tm_cat where tid = id;
		for temp_cat in cs loop
			if checkCat(temp_cat.cat_id) then
				insert into tm_cat values (id, temp_cat.cat_id);
				dbms_output.put_line('one row is inserted to TM_CAT');
			else raise_application_error(-20200,'Invalid Category ID');
			end if;
		end loop;
		open cs;
		fetch cs into temp;
		if cs%notfound then 
			dbms_output.put_line('Error - No row is fetched from cat_TEMP');
		end if;
		close cs;
	end update_cat;
	
	procedure edi_read(edi in out varchar2, qid in out number)
	is  -- checked
		invalid_apt exception;
		pragma exception_init(invalid_apt, -20300);
		invalid_tm_mod exception;
		pragma exception_init(invalid_tm_mod, -20400);		
		invalid_edi_format exception;
		pragma exception_init(invalid_edi_format,-20500);
		tid varchar2(10);  -- Trade Mark ID
		ttxt varchar2(100); -- Trade Mark Text
		adt date; -- Application Date YYYYMMDD
		rmks varchar2(500); -- remarks of the trade mark
		err_code number;
		err_msg varchar2(250);
		str varchar2(1000) := edi;
	begin
		delete from edi_owner_temp;
		delete from edi_cat_temp;
		savepoint s1;
		if checkHF(edi) then
			edi := substr(edi, 10, length(edi)-14);
			edi_split(edi, tid, ttxt,adt, rmks);
			if tid is null then
			 tid := get_tid(); 
				if checkDT(adt) then
					create_tm(tid, ttxt, adt, rmks);
					process_owner(tid, ttxt);
					process_cat(tid, ttxt);
					dbms_output.put_line('one row process complete');		
					dbms_output.put_line(' ');
				else 
					dbms_output.put_line('Trade Mark status error');
					raise_application_error(-20300,'Application Date must be within the current year');	
				end if;
			else 
				if check_tm_status(tid) then
					if checkDT(adt) then 
						update_tm(tid,ttxt,rmks);
						update_owner(tid,ttxt);
						update_cat(tid,ttxt);
						dbms_output.put_line('one row update completed');
						dbms_output.put_line(' ');
					else raise_application_error(-20300,'Application Date must be within the current year');	
					end if; 
				else raise_application_error(-20400,'Trade Mark can no longer be modified');
				end if;
			end if;
		else raise_application_error(-20500,'Invalid edi fomat');
		end if;
	exception
		when others then 
			rollback to s1;		
				err_code := sqlcode;
				err_msg := substr(sqlerrm,1,250);
			insert into edi_error values(qid,str,err_code,err_msg);
			dbms_output.put_line('Error is inserted to EDI_ERROR');
			dbms_output.put_line(' ');
			delete edi_queue where queue_id = qid;
			delete from edi_owner_temp;
			delete from edi_cat_temp;
			commit;
	end edi_read;
	
	procedure processAll
	is
		cursor cs is select * from EDI_QUEUE;
	begin
		for edi in cs loop
			edi_read(edi.edi_string, edi.queue_id);
		end loop;	
	end processAll;
end pck_edi;
/
