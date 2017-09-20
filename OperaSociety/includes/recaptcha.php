<?php
 
// grab recaptcha library
require_once "recaptchalib.php";
 
?>

<?php
	// your secret key
	$secret = "6LfiNiEUAAAAAFJknL2OL_o7xR7wHIJefC4iTM4x";
	 
	// empty response
	$response = null;
	 
	// check secret key
	$reCaptcha = new ReCaptcha($secret);
?>

<?php 
	foreach ($_POST as $key => $value) {
	echo '<p><strong>' . $key.':</strong> '.$value.'</p>';
	}
?>

<?php
	// if submitted check response
	if ($_POST["g-recaptcha-response"]) {
	    $response = $reCaptcha->verifyResponse(
	        $_SERVER["REMOTE_ADDR"],
	        $_POST["g-recaptcha-response"]
	    );
	}
?>