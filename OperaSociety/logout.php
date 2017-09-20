<?php
session_start();
?>
<?php
	//log out user
	if (isset($_SESSION['logged_user_by_sql'])) {
		$olduser = $_SESSION['logged_user_by_sql'];
		unset($_SESSION['logged_user_by_sql']);
    print('<script>window.location.href="index.php";</script>');
	} else {
		$olduser = false;
	}
?>