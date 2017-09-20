<?php
session_start()
?>
<!DOCTYPE html>
<html lang="en">
<head>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Cornell Opera Society</title>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
      <?php if (isset($_SESSION['logged_user_by_sql'])) { ?>
        <script type="text/javascript" src="js/edit.js"></script>
      <?php } ?>
<!--      <script src="js/main.js"></script> -->
      <link rel = "stylesheet" type = "text/css" href = "css/home.css"/>
</head>

<body>

  <div class="w3-top">
    <a href="index.php" class="topcorner"><span>Cornell</span><br><span id = "opera_word">Opera</span><br><span>Society</span></a>
    <div class="w3-bar">
      <div class="w3-right">
        <a href="index.php" class="w3-bar-item">Home</a>
        <div class="dropdown">
          <a href="#" id = "about_btn" class="w3-bar-item">About</a>
          <div class="dropdown-content">
            <a href="aboutUs.php">About Us</a>
            <a href="aboutOpera.php">About Opera</a>
          </div>
        </div>

        <a href="perfGall.php" class="w3-bar-item">Photos</a>
      </div>
    </div>
  </div>


    <div id = 'carousel_ctr'>
      <img class="imagereel" src="OperaImgs/opera_bkg2.jpg">
      <span id = "home_text">
        <p class="edit" name="frank" id="lul" style="color:white">
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

        <?php
          $sql = "SELECT * FROM Text WHERE section = 'frank'";
          $text = $mysqli->query($sql);
          if (!$text) {
            print($mysqli->error);
            exit();
          }
          $row = $text->fetch_assoc();
          $code = $row['content'];
          $newtext = wordwrap($code,70,"<br>\n");
          echo $newtext;
        ?>
        </p>
      </span>

      <div id = "calendar_ctr">
        <a href="events.php"><span id = "calendar">Events Calendar</span></a>
        <div id = "hover_cal"></div>
      </div>

    </div>

</body>
</html>
