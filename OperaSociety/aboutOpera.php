<?php
session_start();
error_reporting(E_ALL ^ E_NOTICE);
//include "header.php";
?>
<!DOCTYPE html>
<html lang="en">
    <head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>About Opera</title>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
      <link rel = "stylesheet" type = "text/css" href = "css/aboutOp.css"/>
      <?php if (isset($_SESSION['logged_user_by_sql'])) { ?>
        <script type="text/javascript" src="js/edit.js"></script>
      <?php } ?>
    </head>
        <script>
            function openNav() {
                document.getElementById("nav_ctr1").style.display = "block";
                document.getElementById("nav_ctr1").style.width = "190px";

            }

            function closeNav() {
                document.getElementById("nav_ctr1").style.display = "none";
                document.getElementById("nav_ctr1").style.width = "0";
            }

            var height = $(document).height();
            document.getElementById("nav_ctr").height(height);
        </script>

<body>
    <?php
       // require the config file to access the database
       require_once "includes/config.php";
       $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
       //Was there an error connecting to the database?
       if ($mysqli->errno) {
        //The page isn't worth much without a db connection so display the error and quit
        print($mysqli->error);
        exit();
      }
    ?>

    <div id="nav_ctr" class= '.lengthen'>
        <a href="index.php" class="topcorner"><span>Cornell</span><br><span id = "opera_word">Opera</span><br><span>Society</span></a>
        <div id="nav_bar">
            <div id="item_ctr">
                <a href="index.php" class="bar-item">Home</a><br><br>
                <a href="#" class="bar-item">About</a><br><br>
                <div id = "dropdown">
                    <a href="aboutUs.php" class = "about-item">About Us</a><br>
                    <a href="aboutOpera.php" class = "about-item">About Opera</a><br><br>
                </div>
                <a href="perfGall.php" class="bar-item">Photos</a>
            </div>
        </div>
        <span id = "calendar"><a href="events.php">Events Calendar</a></span>
    </div>

    <div id="nav_ctr1" style="width: 0;">
        <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
        <a href="index.php" class="topcorner"><span>Cornell</span><br><span id = "opera_word">Opera</span><br><span>Society</span></a>
        <div id="nav_bar">
            <div id="item_ctr1">
                <a href="index.php" class="bar-item">Home</a><br><br>
                <a href="#" class="bar-item">About</a><br><br>
                <div id = "dropdown">
                    <a href="aboutUs.php" class = "about-item">About Us</a><br>
                    <a href="aboutOpera.php" class = "about-item">About Opera</a><br><br>
                </div>
                <a href="perfGall.php" class="bar-item">Photos</a>
            </div>
        </div>
        <span id = "calendar1"><a href="events.php">Events Calendar</a></span>
    </div>

    <div id = "header_img">
        <span onclick="openNav()" id = "show_nav_btn">&#9776</span>
       <img src="OperaImgs/header_aboutopera.jpg">
    </div>

    <div id = "content">
        <h3 class = 'page_title edit' name = 'whatisoperaheader' id = 'whatisoperaID'>
        <?php
              $sql = "SELECT * FROM Text WHERE section = 'whatisoperaheader'";
              $text = $mysqli->query($sql);
              if (!$text) {
                print($mysqli->error);
                exit();
              }
              $row = $text->fetch_assoc();
              $code = $row['content'];
              print $code;
            ?>
        </h3>
        <p class = 'edit group_desc' name='what_is_opera' id='what_isID'>
        <?php
              $sql = "SELECT * FROM Text WHERE section = 'what_is_opera'";
              $text = $mysqli->query($sql);
              if (!$text) {
                print($mysqli->error);
                exit();
              }
              $row = $text->fetch_assoc();
              $code = $row['content'];
              print $code;
        ?>
        </p>
    </div>

</body>

</html>