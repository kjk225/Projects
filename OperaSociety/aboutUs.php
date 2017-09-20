
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
      <title>Cornell Opera Society</title>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
      <?php if (isset($_SESSION['logged_user_by_sql'])) { ?>
        <script type="text/javascript" src="js/edit.js"></script>
      <?php } ?>
      <link rel = "stylesheet" type = "text/css" href = "css/proj_white.css"/>
    </head>
        <script>
            
            $(window).on("scroll", function() {
                if($(window).scrollTop() > 50) {
                    document.getElementById("calendar").style.backgroundColor = "#d31717";
                } else {
                    //remove the background property so it comes transparent again (defined in your css)
                   document.getElementById("calendar").style.backgroundColor = "transparent";
                }
            });

            function openNav() {
                document.getElementById("nav_ctr1").style.display = "block";
                document.getElementById("nav_ctr1").style.width = "190px";
                
            }
            
            function closeNav() {
                document.getElementById("nav_ctr1").style.display = "none";
                document.getElementById("nav_ctr1").style.width = "0";
            }
            
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


    <div id="nav_ctr">
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
    <div id = "nav_help"><div id = "nav_scroll"></div></div>

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
       <img src="OperaImgs/header_aboutus.jpg">
    </div>

    <div id = "content">
        <h3 class = 'page_title edit' name = 'aboutusheader' id = 'aboutusheaderID'>
          <?php
              $sql = "SELECT * FROM Text WHERE section = 'aboutusheader'";
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
        
        <p class = 'edit group_desc' name='ClubDescrip' id='ClubDescripID'>
            <?php
              $sql = "SELECT * FROM Text WHERE section = 'ClubDescrip'";
              $text = $mysqli->query($sql);
              if (!$text) {
                print($mysqli->error);
                exit();
              }
              $row = $text->fetch_assoc();
              $code = $row['content'];
              print $code;
            ?>

        <a id="sendContact" href="#"></a>
          <div id="links" class="hidden group_desc">
            <br>
            <a style="color:white;background-color:#d31717;padding:10px;" href="mailto:cornellopera@gmail.com">Contact Cornell Opera</a>
          </div>
        </p>
        <br>
        <h3 class = 'page_title edit' name = 'membersheader' id = 'membersheaderID'>
          <?php
              $sql = "SELECT * FROM Text WHERE section = 'membersheader'";
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

        <p class = 'group_desc edit' name='groupDesc' id='groupDescID'>
            <?php
              $sql = "SELECT * FROM Text WHERE section = 'groupDesc'";
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

        <table class = 'group_desc' name='MemberDisp' id='MemberDisp'>
          <tr>
            <th>Name</th>
            <th>Position</th>
            <th>Major</th>
            <th>Class</th>
          </tr>
            <?php
              $sql = "SELECT * FROM Members";
              $members = $mysqli->query($sql);
              $mem_rows = $members->num_rows;
              for ($i = 0; $i < $mem_rows; $i++) {
                $mem = $members->fetch_assoc();
                $name = $mem['name'];
                $position = $mem['position'];
                $major = $mem['major'];
                $class = $mem['class'];
                print("
                  <tr>
                    <td>$name</td>
                    <td>$position</td>
                    <td>$major</td>
                    <td>$class</td>
                  </tr>
                  ");

              }
            ?>
        </table>

<?php

if (isset($_SESSION['logged_user_by_sql'])) {
    print('
    <div class= "group_desc">
    <h2> Edit the Members of the Opera Society </h2>
    <h3> Add a New Member </h3>
    <form method="post" enctype="multipart/form-data">
      Name<input type="text" name="names"  id="names" size="50"/>
      Position<input type="text" name="position"  id="position" size="50"/></br>
      Major<input type="text" name="major"  id="major" size="50"/>
      Class<input type="number" name="class"  id="class" size="50"/>
      <input type="submit" value="AddMember" name="AddMember" />
    </form>
    </div>');

  print '<pre style="display:none;">' . print_r( $_FILES, true ) . '</pre>';
  //echo $originalName;
  $name= filter_input(INPUT_POST, 'names', FILTER_SANITIZE_STRING);
  $position = filter_input(INPUT_POST, 'position', FILTER_SANITIZE_STRING);
  $major = filter_input(INPUT_POST, 'major', FILTER_SANITIZE_STRING);
  $class=$_POST[ 'class' ];
  $memSub = $_POST['AddMember'];
  if (($name==NULL||$position==NULL|| $major==NULL || $class==NULL)) {
      echo "<div class='group_desc' style ='color:#d31717'>All fields are required. </div>";
  } else  {

  // This is the errors function that validates each input
  function errors($name, $position, $major, $class, $originalName){

     // echo "vvvv";
      if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $name)){

      echo "Invalid Entry for $name";
      return;
  }
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $position)){
      echo "Invalid Entry for $position";
      return;
  }

  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $major)){
      echo "Invalid Entry for $major";
      return;
  }
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $class)){
      echo "Invalid Entry for $class";
      return;
  }

  if ($name===""||$position===""||$major===""||$class===""||$originalName===""){
          echo "<div style ='color:#ff0000'>All fields are required. </div>";
          echo "<div style ='color:#ff0000'>
          Confirm that input does not consist of special program codes</div>";
          return;
      }
   if ($class< 2010 || $class > 2030){
      echo " Invalid entry for class; this should be the graduating year";
      return;
  }
   // This checks for duplicate entry; checks if the name is already in the database and breaks if that is the case
     $result4 = $mysqli->query("SELECT * FROM Images");
      $bool=array();
      while ($row = $result4->fetch_row()){
          if (strtolower("membImg/".$originalName)===strtolower($row[1]) && strtolower($name)===strtolower($row[3])
              && strtolower($major)===strtolower($row[2])){
          array_push($bool,1);
          }
      }
              if (in_array(1,$bool)){
              echo "<div style ='color:#ff0000'>Image Must be Unique </div>";
          echo "<div style ='color:#ff0000'>
          The above member already Exists</div>";
          return;
      }
  }

  $sql_add = "INSERT INTO Members (name, position, major, class, image_path) VALUES ('$name', '$position', '$major', '$class', 'hi')";
  echo('<meta http-equiv="refresh" content="0">');
  $results = $mysqli->query($sql_add);
  if (!$results) {
      print($mysqli->error);
      exit();
  } else {
     echo "<h1 class='center'>The photo has been added.</h1>";
  }
}


  print('
  <div class ="group_desc">
  <h3 > Delete an Existing Member </h3>
  <form method="post" enctype="multipart/form-data">
       Name<input type="text" name="del"  id="del" size="50"/>
      <br>
      <input type="submit" value="Done" name="Done" />
  </form>
  </div>');

  print '<pre style="display:none;">' . print_r( $_FILES, true ) . '</pre>';



  if (!empty($_POST["Done"]) && !empty($_POST["del"]) ){
      $del = filter_input(INPUT_POST, 'del', FILTER_SANITIZE_STRING);
    if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $del)){
        echo "Invalid Entry for $del, must not contain the following '\'^£$%&*()}{@#~?><>|=+¬'";
        return;
    }

    // This is to check if you are trying to delete a non-existant member, and should return in this case
    $result5 = $mysqli->query("SELECT * FROM Members");
    $sqli = "DELETE FROM Members WHERE name= '$del'";
    $result_delete = $mysqli->query($sqli);
    echo('<meta http-equiv="refresh" content="0">');
    if ($result_delete) {
      echo "$del deleted successfully";
    } else {
      echo "Could not be deleted";
    }

  }
}


?>
  <?php

        if (isset($_SESSION['logged_user_by_sql'])) {
          print('<div class="footer"><a href = "logout.php">Administrator Logout</a></div>');

        }
        else {
           print('<div class="footer"><a href = "login.php">Administrator Login</a></div>');
        }
        ?>
  </div>
</body>

</html>