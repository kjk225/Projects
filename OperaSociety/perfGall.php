<?php
session_start();
error_reporting(E_ALL ^ E_NOTICE);
//include "header.php";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <?php include("includes/thumbnail.php");?>
    <!--<?php include("search.php");?>-->
    <?php if (isset($_SESSION['logged_user_by_sql'])) { ?>
        <script type="text/javascript" src="js/edit.js"></script>
    <?php } ?>
    <link rel = "stylesheet" type = "text/css" href = "css/gall.css"/>
    <script src="js/gall.js"></script>
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Cornell Opera Society</title>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
</head>

<body>

          <script>
            function openNav() {
                document.getElementById("nav_ctr1").style.display = "block";
                document.getElementById("nav_ctr1").style.width = "170px";

            }

            function closeNav() {
                document.getElementById("nav_ctr1").style.display = "none";
                document.getElementById("nav_ctr1").style.width = "0";
            }

            var height = $(document).height();
            document.getElementById("nav_ctr").height(height);
        </script>

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
    </div>

    <?php
       // require the config file to access the database
       require_once "includes/config.php";
       $mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
       //Was there an error connecting to the database?
       if ($mysqli->error) {
        //The page isn't worth much without a db connection so display the error and quit
        print($mysqli->error);
        exit();
      }

      $sql = 'SELECT * FROM Performances';
      $performances = $mysqli->query($sql);
      if (!$performances) {
        print($mysqli->error);
        exit();
      }

      $performance_rows = $performances->num_rows;
    ?>

    <!-- sidebar div for links on pages -->

    <?php
    if(!empty($_POST['add'])) {
          //Try to retrieve values from the POST data
          if(!empty($_POST['title'] && !empty($_POST['composer']))) {
            $title = filter_input(INPUT_POST, 'title', FILTER_SANITIZE_STRING);
            $title = trim($title);
            $composer = filter_input(INPUT_POST, 'composer', FILTER_SANITIZE_STRING);
            $composer = trim($composer);
            $sql_add = "INSERT INTO Performances (title, composer, era, description) VALUES ('$title', '$composer', '1989','Bizzare Summer')";
          } else {
            print "<p class='center'>Please fill both fields.</p>";
          }
          //Anything to save?
          if(!empty($sql_add)) {
            if($mysqli->query($sql_add)) {
              print "<p class='center'>... Added $title to website.</p>";
            } else {
              // $message = "<p class='center'>Error saving.</p><p>$mysqli->error</p>";
              print "rip";
            }
          }
    }
    ?>

    <!-- search division -->
      <div class="searchBar">
        <p class = "edit" id = "galleryDesc" name = "gallDes"></p>
        <form method="post">
              <input type="text" placeholder="Search for Images" name="s" id="inputSearch" maxlength="255">
              <input type="submit" class="submit-button" name="search" value="search">
        </form>
        <a href='perfGall.php'> <input type='submit' class='submit-button' name='Display All' value='display all'></a>
      </div>

    <?php if (!empty($_POST['s'])) {
      //Search Keyword
      $keyword = filter_input(INPUT_POST, 's', FILTER_SANITIZE_STRING);
    } else {
      $keyword = "";
    }
    ?>
   <!--div for image gallery/slider-->

    <div id = "content">

    <?php
      if (!isset($_POST['s']) && !isset($_GET['performance_id'])) {
            $sql3 = "SELECT * FROM Images";
            $photos = $mysqli->query($sql3);
            $photo_rows = $photos->num_rows;
            echo"<div class='row'>";
            for ($i = 0; $i < $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //display the images within a certain performance
                  echo"
                    <div class='column'>
                      <img src='$file_path' onclick='openModal();currentSlide($i+1)' class='hover-shadow'>
                    </div>";
            }
            echo"</div>";
            echo"<div id='myModal' class='modal'>
                    <span class='close cursor' onclick='closeModal()'>&times;</span>
                  <div class='modal-content'>";
            $sql3 = "SELECT * FROM Images";
            $photos = $mysqli->query($sql3);
            $photo_rows = $photos->num_rows;
            for ($i = 1; $i <= $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //for javascript large display
                    echo"
                    <div class= 'mySlides' id= '$caption'>
                        <img class='resize' src='$file_path'>
                    </div>";

            }
            echo"
                <a class='prev' onclick='plusSlides(-1)'>&#10094;</a>
                <a class='next' onclick='plusSlides(1)'>&#10095;</a>
              </div>
              <div class='caption-container'>
                  <p id='captionSlider'></p>
              </div>
            </div>";
          }

        else if (isset($_GET['performance_id'])){
            $performance_id = filter_input(INPUT_GET, 'performance_id', FILTER_SANITIZE_NUMBER_INT);
            $sql2 = 'SELECT * FROM Performances WHERE performance_id = ' . $performance_id .';';
            $performances = $mysqli->query($sql2);
            $performance = $performances->fetch_assoc();
            $title = $performance['title'];
            print "<h2 class='header3'>$title</h2>";
            $sql3 = "SELECT * FROM Images WHERE Images.performance_id in (SELECT performance_id FROM Performances WHERE performance_id = '$performance_id')";
            $photos = $mysqli->query($sql3);
            $photo_rows = $photos->num_rows;
            echo"<div class='row'>";
            for ($i = 0; $i < $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //display the images within a certain performance
                  echo"
                    <div class='column'>
                      <img src='$file_path' onclick='openModal();currentSlide($i+1)' class='hover-shadow'>
                    </div>";
            }
            echo"</div>";
            echo"<div id='myModal' class='modal'>
                    <span class='close cursor' onclick='closeModal()'>&times;</span>
                  <div class='modal-content'>";
            $photos = $mysqli->query($sql3);
            $photo_rows = $photos->num_rows;
            for ($i = 1; $i <= $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //for javascript large display
                    echo"
                    <div class= 'mySlides' id= '$caption'>
                        <img class='resize' src='$file_path'>
                    </div>";

            }
            echo"
                <a class='prev' onclick='plusSlides(-1)'>&#10094;</a>
                <a class='next' onclick='plusSlides(1)'>&#10095;</a>
                <div class='caption-container'>
                  <p id='captionSlider'></p>
                </div>
              </div>
            </div>";

        }

    else { //Submit was pressed for Search

        $sql2 = "SELECT image_id, name, caption, Images.description, Images.performance_id, path, Performances.title FROM Images INNER JOIN Performances ON
            Images.performance_id = Performances.performance_id WHERE
                (
                 name LIKE '%$keyword%'
                 OR caption LIKE '%$keyword%'
                 OR Images.description LIKE '%$keyword%'
                 )
                 ";

        if (!empty($_POST['s'])) {
          $performances = $mysqli->query($sql);
          $photos = $mysqli->query($sql2);

          if($photos AND $photos->num_rows >= 1) {
            $photo_rows = $photos->num_rows;
            for ($i = 0; $i < $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //display the images within a certain performance
                  echo"
                    <div class='column'>
                      <img src='$file_path' onclick='openModal();currentSlide($i+1)' class='hover-shadow'>
                    </div>";
            }
            echo"</div>";
            echo"<div id='myModal' class='modal'>
                    <span class='close cursor' onclick='closeModal()'>&times;</span>
                  <div class='modal-content'>";
            $photos = $mysqli->query($sql2);
            $photo_rows = $photos->num_rows;
            for ($i = 0; $i < $photo_rows; $i++) {
                  $photo = $photos->fetch_assoc();
                  $image_id = $photo['image_id'];
                  $file_path = $photo['path'];
                  $name = $photo['name'];
                  $caption = $photo['caption'];
                  //for javascript large display
                    echo"
                    <div class='mySlides' id='$caption'>
                        <img class='resize' src='$file_path' style='width:50%'>
                    </div>";

            }
            echo"
                <a class='prev' onclick='plusSlides(-1)'>&#10094;</a>
                <a class='next' onclick='plusSlides(1)'>&#10095;</a>
                <div class='caption-container'>
                  <p id='captionSlider'>$caption</p>
                </div>
              </div>
            </div>";
          } else {
            echo("<h2>No images found in search.</h2>");
          }
      } else {
        echo("<h2>No images found in search.</h2>");
      }
      }
      ?>

<?php if (isset($_SESSION['logged_user_by_sql'])) {
  print('
    <div class = "addPhoto">
    <br>
    <h3 id = "editHeader"> Edit Photos of the Opera Society </h3>
    <form method="post" enctype="multipart/form-data">
      Caption<input type="text" name="caption"  id="caption" size="50"/></br>
      Title<input type="text" name="title"  id="title" size="50"/></br>
      Date Taken<input type="date" name="date"  id="date" size="50"/></br>
      Description<input type="text" name="desc"  id="desc" size="50"/></br>
      Photo upload<input type="file" name="newphoto"/><br/>
       <input type="submit" value="UploadPhoto" name="UploadPhoto"/>
    </form>');
  print '<pre style="display:none;">' . print_r( $_FILES, true ) . '</pre>';
  $newPhoto = $_FILES[ 'newphoto' ];
  $originalName = $newPhoto['name'];
  $caption= filter_input(INPUT_POST, 'caption', FILTER_SANITIZE_STRING);
  $title =filter_input(INPUT_POST, 'title', FILTER_SANITIZE_STRING);
    //  $file = $_POST[ 'file' ];
    //$album=$_POST[ 'album' ];
  $date=$_POST[ 'date' ];
  $desc = filter_input(INPUT_POST, 'desc', FILTER_SANITIZE_STRING);
  $setPhoto = $_POST['UploadPhoto'];
  if (($caption==NULL||$title==NULL|| $originalName==NULL|| $date==NULL || $desc ==NULL)) {
      echo "<div style ='color:#ff0000'>All fields are required, including an image </div>";
  }
  else {
    //VALIDATES ALL INPUT BEFORE TRYIN TO UPLOAD IT
  function errors($caption, $title, $originalName, $date, $desc){
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $caption)){
  echo "Invalid Entry for $caption";
  return;
  }
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $desc)){
  echo "Invalid Entry for $desc";
  return;
  }
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $title)){
  echo "Invalid Entry for $title";
  return;
  }
  if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $date)){
  echo "Invalid Entry for $date";
  return;
  }
  $parts=pathinfo($originalName);
  if(strtolower($parts['extension']) != "jpg"){
  if (strtolower($parts['extension']) != "jpeg"){
  if (strtolower($parts['extension']) != "png"){
  echo "<div style ='color:#ff0000'>Attempt to upload wrong file </div>";
  echo "<div style ='color:#ff0000'>
    Only jpg, jpeg and png allowed</div>";
  return;
  }
  }}
  if (preg_match('[ ]', $originalName)){
  echo "Image name cannot have spaces";
  return;
  }
}
  // THIS IS AN ATTEMPT TO ACTUALLY SET THE IMAGE ID, IT CHECKS IN THEDB FOR UNASSIGNED IDS AND TAKES FROM THE LOWEST
  $result_1 = $mysqli->query("SELECT * FROM Images");
  $bool=array();
  while ($row = $result_1->fetch_row()){
  array_push($bool,$row[0]);
  }
  // BOOL IS ALL THE IDS IN THE DB
  sort($bool);
  //TO GET THE SMALLEST IMAGE_ID NOT IN THE TABLE
  $number = 1;
  while (in_array($number,$bool)){
    $number = $number +1;
  }
  array_push($bool,$number);
  // BEFORE ADDING TO PERFORMANCE, CHECK IF THE PERFORMANCE ID EXISTS
  $result_2 = $mysqli->query("SELECT * FROM Performances");
  $bool2=array();
  $id = 1;
  //INSERT NOW
  $s10 = "INSERT INTO Images (image_id, name, caption, description, date, performance_id, path)
  VALUES ('$number','$title', '$caption', '$desc', '$date', '$id', 'OperaImgs/$originalName')";//, $date1)";
  $mysqli->query($s10);
  var_dump($s10);
  echo('<meta http-equiv="refresh" content="0">');
}

  //DELETE A PHOTO

  print('
  <div class="delPhoto">
  </br>
  <form method="post" enctype="multipart/form-data">
    Enter Image Name to Delete<input type="text" name="del"  id="del" size="50"/></br>
    <input type="submit" value="Delete" name="Delete" />

  </form>
  </div>');

  if(!empty($_POST['Delete'])) {
    print '<pre style="display:none;">' . print_r( $_FILES, true ) . '</pre>';
    if (isset($_POST["Delete"])) {
        $del = filter_input(INPUT_POST, 'del', FILTER_SANITIZE_STRING);
        if ($del==="") {
        echo "<div style ='color:#ff0000'> Please enter name to be deleted </div>";
        echo "<div style ='color:#ff0000'>
          Confirm that input does not consist of special program codes</div>";
          return;
        }
        if (preg_match('/[\'^£$%&*()}{@#~?><>|=+¬]/', $del)){
          echo "Invalid Entry for $del, must not contain the following '\'^£$%&*()}{@#~?><>|=+¬'";
          return;
        }
        $result_5 = $mysqli->query("SELECT * FROM Images");
        $b= array();
        while ($row = $result_5->fetch_row()){
          array_push($b,$row[2]);
        }
        if (!in_array($del, $b)){
          echo "<div style ='color:#ff0000'> </div>";
          echo "<div style ='color:#ff0000'>
          That Image does not Exist</br> Note that the name is case sensitive</div>";
          return;
        }
        $sqli = "DELETE FROM Images WHERE caption= '$del'";
        if  (mysqli_query($mysqli, $sqli)){
          echo('<meta http-equiv="refresh" content="0">');
        }
        else{
          echo "Could not be deleted";
          return;
        }
      }
    }
  }
?>
</body>
</html>
