window.onload = function() {

var slideIndex = 0;
carousel();

$(".icon").click(function() {
    navIcon();
});

function navIcon() {
    var x = document.getElementById("myTopnav");
    if (x.className === "topnav") {
        x.className += " responsive";
    } else {
        x.className = "topnav";
    }
}

function carousel() {
    var i;
    var x = document.getElementsByClassName("imagereel");
    for (i = 0; i < x.length; i++) {
      x[i].style.display = "none";
    }
    slideIndex++;
    if (slideIndex > x.length) {slideIndex = 1;}
    $(x[slideIndex-1]).fadeIn(500);
    $(x[slideIndex-1]).delay(8000);
    $(x[slideIndex-1]).fadeOut(500);
    setTimeout(carousel, 9000);
    }
}
