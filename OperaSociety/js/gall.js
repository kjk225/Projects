function openModal() {
  document.getElementById('myModal').style.display = "block";
}

  function closeModal() {
  document.getElementById('myModal').style.display = "none";
}

var slideIndex = 1;

function plusSlides(n) {
  showSlides(slideIndex += n);
}

function currentSlide(n) {
  showSlides(slideIndex = n);
}

function showSlides(n) {
  var i;
  var slides = document.getElementsByClassName("mySlides");
  var imager = document.getElementsByClassName("resize");
  var captionText = document.getElementById("captionSlider");
  if (n > slides.length) {slideIndex = 1;}
  if (n < 1) {slideIndex = slides.length;}
  for (i = 0; i < slides.length; i++) {
    slides[i].style.display = "none";
  }
  slides[slideIndex-1].style.display = "block";
  imager[slideIndex-1].style.height = "480px";
  imager[slideIndex-1].style.width = "800px";
  imager[slideIndex-1].style.border = "100px";
  console.log(slides[slideIndex-1]);
  var s =  slides[slideIndex - 1];
  console.log(s.id);
  captionText.innerHTML = slides[slideIndex - 1].id;
}

