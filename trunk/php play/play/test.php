<html>
<head>
	<title>play</title>
	<link rel="stylesheet" type="text/css" href="reset-min.css">
	<link rel="stylesheet" type="text/css" href="main.css"> 	
	<script type="text/javascript" src="jquery.js"></script>	
	<script type="text/javascript">				
		$(function () {
			$("#info").mousedown(function () {
				var $this = jQuery(this);
				console.debug("hello!!!!")
				$.get("info.php", {ding: "hello DING!", dong: "goodbye DONG!"}, function (data) {
					$this.after(data);					
				});
			});
			
		});
	</script>
</head>
<body>
<div id="info">INFO!!!!</div>
<?php	
	/////
	//DATABASE
	/////
	// create new database using the OOP approach
	unlink("facilities.sqlite");
	$db=new SQLiteDatabase("facilities.sqlite");

	// create table 'USERS' and insert sample data
	$db->query("BEGIN;
		CREATE TABLE facility 
			(id INTEGER PRIMARY KEY, name, aliases, machines);
		CREATE TABLE machines 
			(id INTEGER PRIMARY KEY, name, page, version, system_number, options);	
		
	    INSERT INTO facility (id, name, aliases) VALUES 
			(NULL,'Nitor','Singapore, that facility');
		INSERT INTO facility (id, name, aliases) VALUES 
			(NULL,'RCMP','');	
	COMMIT;");	
	
	// fetch rows from the 'USERS' database table
	//$result = $db->query("SELECT name FROM facility");
//	
//	// loop over rows of database table
//	while ($result->valid()) {
//		// fetch current row
//		$row = $result->current();
//		print_r($row[0] . "<br/>");
//		
//		// move pointer to next row
//		$result->next();
//	}

	// modify database

	// get stuff from info.php


	/////
	// FILES
	/////
	function printCode($string) {
		echo "<pre>" . $string . "\t" . "</pre>";
	}
	// read a file and echo
	$testfileGet = @file_get_contents("test.txt");
	printCode($testfileGet);


	// create a file and echo
	@file_put_contents("test_create.txt", "\txxxding dong\nking kong");
	$testfileCreate = @file_get_contents("test_create.txt");
	printCode($testfileCreate);

	// modify a file and echo
	@file_put_contents("test_modify.txt", "change\n"/*, FILE_APPEND*/);
	$testfileModify = @file_get_contents("test_modify.txt");
	printCode($testfileModify);

	
	/////
	// XML
	/////
	// read in an xml file
	$xml = simplexml_load_file("test.xml");

	foreach($xml->xpath('//name') as $rangeName) {
		echo $rangeName . "<br />";	
	}

	// modify an xml file
	$ranges = $xml->xpath('//range[name="xxx"]');
	$ranges[0]->name = xxx;
	$xml->range[0]->name = "++++xxx$$$$ +++++";
	foreach($xml->xpath('//name') as $rangeName) {
		echo $rangeName . "x <br />";	
	}
	echo "hello xml --> " . $ranges[0]->name;
	echo '<pre>' . $xml->asXML() . '</pre>';
	@file_put_contents("test.xml", $xml->asXML());

	// create an xml file

		
?>
</body>
</html>