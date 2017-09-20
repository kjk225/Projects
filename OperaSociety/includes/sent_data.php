<?php
   // require the config file to access the database
   require_once "config.php";
   $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
   //Was there an error connecting to the database?
   if ($mysqli->errno) {
    //The page isn't worth much without a db connection so display the error and quit
    print($mysqli->error);
    exit();
  }
?>

<?php
  // have to sanitize
  //Look up which section has to be edited
  // $length = $_POST['i'];
  // echo basename($_SERVER['PHP_SELF']);
  // $contents = array();
  // for ($i = 0; $i < $lenth; $i++) {
  //  array_push($contents, $mysqli->real_escape_string($_POST['content' . $i]));
  // }
  $section = filter_input(INPUT_POST, 'section', FILTER_SANITIZE_STRING);
  echo $section;
  //Get content:
  //Don't want to sanitize this...
  $content = $_POST['content'];
  echo $content;
  $content = $mysqli->real_escape_string($content);
  $content = str_replace(array('<div>','</div>'), '', $content)
?>

<?php

  $sql = "UPDATE Text SET content = '$content' WHERE section = '$section' ";
  print 
  $edit = $mysqli->query($sql);
  if (!$edit) {
    print($mysqli->error);
    echo "<p> Changes failed to save </p>";
    exit();
  } else {
    echo "<p> Successfully saved changes. </p>";
  }
?>