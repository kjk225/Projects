<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Cornell Opera Society</title>
    <link rel = "stylesheet" type = "text/css" href = "css/events.css"/>
</head>

<body>
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

    <div id="content">
      <!--<div id="content">
        <h1>Events</h1>
        <h4>
          <a href="">
            Lorem Ipsum</a>
        </h4>
        <h5> Lorem Ipsum </h5>
        <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
        <h4>
          <a href="">
          Lorem </a>
        </h4>
        <h5> Lorem Ipsum </h5>
        <p> Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        </p>
        <h4>
          <a href="">Lorem</a>
        </h4>
        <h5> Lorem </h5>
        <p>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        </p>
      </div>-->
      <iframe id='calendrar' src="https://calendar.google.com/calendar/embed?src=cornellopera%40gmail.com&ctz=America/New_York" style="border: 0" frameborder="0" width=100% height=100% scrolling="no"></iframe>
    </div>
</body>
</html>