<?php
session_start();
//include "header.php";
?>
<?php
    $all_pages = array(
        'Home' => 'index.php',
        'About Us' => 'aboutUs.php',
        'About Opera' => 'aboutOpera.php',
        'Contact' => 'contact.php',
        'Events' => 'events.php',
        'Gallery' => 'perfGall.php'
    );
    print('
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Cornell Opera Society</title>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
      <script src="js/main.js"></script>
      <link rel = "stylesheet" type = "text/css" href = "css/proj.css"/>
      <div id="header">
      <div id="logo">
        <div id="logo_text">
          <h1><a href="index.php">Cornell Opera Society</a></h1>
        </div>
      </div>
      </div>
      <div class="topnav" id="myTopnav">');
      foreach ( $all_pages as $title => $link ) {
        echo("<a href='$link'>$title</a>");
      }
      if (!isset($_SESSION['logged_user_by_sql'])) {
        echo("<a href='login.php'>Login</a>");
      }
      if (isset($_SESSION['logged_user_by_sql'])) {
        echo("<a href='edit.php'>Edit</a>");
        echo("<a href='logout.php'>Log Out</a>");
      }
    print('
      <a href="javascript:void(0);" class="icon">&#9776;</a>
      </div>');
?>
