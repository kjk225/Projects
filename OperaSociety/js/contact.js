window.onload = function() {
  $("#sendContact").on("click", function(event) {
    event.preventDefault();
    $("#iframes").empty();
    $("#links a").each(function() {
      setTimeout($.proxy(function() {
        var popup = window.open($(this).attr("href"))
        setTimeout($.proxy(function() {
          this.close();
        }, popup), 100);
      }, this), 100)
    })
  })
};