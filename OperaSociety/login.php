<?php
session_start();
error_reporting(E_ALL ^ E_NOTICE);
?>

<!DOCTYPE html>
<html lang="en">
<head>
	<title>Login</title>
    <meta charset="utf-8">
      <meta charset="utf-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
	  <link rel = "stylesheet" type = "text/css" href = "css/proj_white.css"/>
      <title>Cornell Opera Society</title>
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
            
        </script>

<body>
	
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

	
	
<div id = "login_ctr">
    <?php
		$post_username = filter_input( INPUT_POST, 'username', FILTER_SANITIZE_STRING );
		$post_password = filter_input( INPUT_POST, 'password', FILTER_SANITIZE_STRING );
		if ( empty( $post_username ) || empty( $post_password ) ) {
		?>
			<?php if (!isset($_SESSION['logged_user_by_sql'])) { ?>
			<h3 class = 'page_title'>Log In</h3>
			<form action="login.php" method="post">
				Username: <input type="text" name="username"> <br>
				Password: <input type="password" name="password"> <br>
				<input type="submit" value="Submit">
			</form>
			<?php } ?>

		<?php

		} else {
			require_once 'includes/config.php';
			$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
			if( $mysqli->connect_errno ) {
				//uncomment the next line for debugging
				//echo "<p>$mysqli->connect_error<p>";
				die( "Couldn't connect to database");
			}
			$query = "SELECT *
						FROM users
						WHERE
							username = ?";
			$stmt = $mysqli->stmt_init();

			if ($stmt->prepare($query)) {
				$stmt -> bind_param('s', $post_username);
				$stmt -> execute();
				$result = $stmt->get_result();
				//Make sure there is exactly one user with this username
				if ( $result && $result->num_rows == 1) {
					//echo $post_username;
					$row = $result->fetch_assoc();
					$db_hash_password = $row['hashpassword'];

					$valid=password_verify( $post_password, $db_hash_password );
					//echo $valid;
					//echo $post_username;
					if($valid)  {
						$db_username = $row['username'];
						$_SESSION['logged_user_by_sql'] = $db_username;
					}

				}
			}

			$mysqli->close();

			if ( isset($_SESSION['logged_user_by_sql'] ) ) {
				print("<p>Welcome, $db_username. ...redirecting<p>");
				echo '<script>window.location.href = "index.php";</script>';

			} else {
				echo '<p>Invalid username/password.</p>';
				echo '<form action="login.php">
    						<input type="submit" value="Try again?" />
							</form>';
			}

		}

		?>
</div>
</body>
</html>