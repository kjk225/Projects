<!DOCTYPE html>
<html lang="en">
<head>
    <?php include("includes/header.php");?>
    <script src='https://www.google.com/recaptcha/api.js'></script>
    <?php include("includes/recaptcha.php");?>
</head>

<body>

    <?php
        // define variables and set to empty values
        $nameErr = $emailErr = $radioErr = $dropdownErr = $commentErr = "";
        $name = $email = $message = "";
        //get the name of the sender
        if ($_SERVER["REQUEST_METHOD"] == "POST") {
            if (empty($_POST["name"])) {
                $nameErr = "Name is required";
            } else {
                $name = test_input($_POST["name"]);
                // check if name only contains letters and whitespace
                if (!preg_match("/^[a-zA-Z ]*$/",$name)) {
                    $nameErr = "Only letters and white spaces are allowed";
                }
            }

            if (empty($_POST["email"])) {
                $emailErr = "Email is required";
            } else {
                $email = test_input($_POST["email"]);
                // check if e-mail address is well-formed
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    $emailErr = "Invalid email format";
                }
            }
            if (empty($_POST["message"])) {
                $message = "";
            } else {
                $message = test_input($_POST["message"]);
            }
            // if (empty($_POST["button"])) {
            //     $radioErr = "Please pick one of the choices";
            // }
            // if (empty($_POST["dropdown"])) {
            //     $dropdownErr = "Please pick one of the choices";
            // }
        }

        function test_input($data) {
          $data = trim($data);             //remove unnecessary characters
          $data = stripslashes($data);     //remove \
          $data = htmlspecialchars($data); //convert to html chars
          return $data;
        }
    ?>

    <!-- FORM -->
    <h2>Get in touch!</h2>
    <p><span class="error">* required field.</span></p>
    <form method="post" action="<?php
    echo htmlspecialchars($_SERVER["PHP_SELF"]);?>">
      <?php require_once('/includes/recaptchalib.php');
      $publickey = "your_public_key"; // you got this from the signup page
      echo recaptcha_get_html($publickey); ?>

      Name: <input type="text" name="name" placeholder="Your Name"
       size ="30" value="<?php echo $name;?>">
      <span class="error">* <?php echo $nameErr;?></span>
      <br><br>
      E-mail: <input type="text" name="email" placeholder="Your Email"
       size ="30" value="<?php echo $email;?>">
      <span class="error">* <?php echo $emailErr;?></span>
      <br><br>
      Message: <textarea name="message" rows="5" cols="40">
      </textarea>
      <span class="error">* <?php echo $commentErr;?></span>
      <br><br>
      <div class="g-recaptcha" data-sitekey="6LfiNiEUAAAAAIoVGN63Ymk0ohGMaZPOMElw3eu0" data-theme="dark"></div>
      <input type="submit" name="send" value="Send">
    </form>


    <?php
    //if "email" variable is filled out, send email
    if (isset($_POST["email"], $_POST["name"], $_POST["comment"]) and $emailErr === "")  {

            //Email information
        $admin_email = "gg392x@gmail.com";
        $email = $_POST["email"];
        $subject = $_POST["name"];
        $message = $_POST["messege"];
        $subject = "OperaSociety: New Message from $name!";

        echo "<p></p>";
        echo "Thank you for contacting the Cornell Opera Society!";
        echo "<p></p>";
        //send email
        //Email response

        mail($admin_email, $subject, $message, "From: " . $email);
        mail($email, $subject, "You sent a message to the Cornell Opera Society: " . $message);
    }

    ?>

</body>
</html>
