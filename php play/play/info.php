<?php
	//echo '<div>', $_GET['ding'] . " (WHAT?)</div><div>", $_GET['dong'] . "[hey!!!xxx]</div>";
	// fetch rows from the 'USERS' database table
	$db = new SQLiteDatabase("facilities.sqlite");
	$db->query("BEGIN;		
	    INSERT INTO facility (id, name, aliases) VALUES 
			(NULL,'".$_GET['ding']."','Singapore, that facility');
		INSERT INTO facility (id, name, aliases) VALUES 
			(NULL,'".$_GET['dong']."','');	
	COMMIT;");		
	
	$result = $db->query("SELECT name FROM facility");	
	

	// loop over rows of database table
	while ($result->valid()) {
		// fetch current row
		$row = $result->current();
		print_r($row[0] . "<br/>");
		
		// move pointer to next row
		$result->next();
	}
	passthru("notepad");
?>