window.onload = function() {
    var content = $('.content'),
        cancel = 0;
          edit = $('.edit');
          edit.attr('contenteditable', 'true');
          $('.edit').on('click', function(e) {
            // console.log(cancel);
            if (cancel == 0) {
                // console.log('yay');
                cancel = 1;
                var id = e.target.id;
                var id = '#' + id;
                if (id == '#') {
                } else {
                      // var name = $(this).;
                      // var classname = '[name="' + nameAttributeValue + '"]'
                      // edit.append('<button>Save</button>');
                      // console.log(id);
                      // if ($(id).attr('correct') == 1) {           
                      // } else {
                    $("<button class ='cancelbutton'>Cancel</button>").insertBefore(id);
                    $("<button class ='editbutton'>Save</button>").insertAfter(id);
                    // $("<button class ='redhighlight'>Highlight</button>").insertAfter(id);
                    // $("<button class ='normaltext'>Text</button>").insertAfter(id);
                }
                $(".edit:not("+id+")").attr('contenteditable', 'false');
            }
                // $(id).attr('correct',1);
                $('.cancelbutton').on('click', function() {
                    $('.editbutton').remove();
                    $('.redhighlight').remove();
                    $('.normaltext').remove();
                    $('.cancelbutton').remove();
                    cancel = 0;
                    $(id).attr('contenteditable', 'false');
                    edit.attr('contenteditable', 'true');
                });
                $('.redhighlight').on('click', function() {
                   $(id).append('<span style="font-weight: 900; background-color: rgb(211, 23, 23);">text&nbsp;</span>'); 
                });
                $('.normaltext').on('click', function() {
                   $(id).append('text '); 
                });

                $('.editbutton').on('click', function() {
                  // $('.editbutton').attr("disabled", true);
                  // $('.redhighlight').attr("disabled", true);
                  // $('.normaltext').attr("disabled", true);
                  $('.editbutton').remove();
                  $('.redhighlight').remove();
                  $('.normaltext').remove();
                  $('.cancelbutton').remove();                  
                  // $(id).attr('correct',0);
                  // console.log($(id).html());
                  var content = $(id).html();
                  var name = $(id).attr('name');
                  data = {'content':content, 'section':name};
                  console.log(name);
                  console.log(content);
                  $.ajax({
                      type: 'post',
                      url: 'includes/sent_data.php',
                      // dataType:'json',
                      data: data,
                      success: function (response) {
                          // console.log(data);
                          // console.log("Success");
                          $("<p class='deletethis'>Changes Saved</p>").insertAfter(id);
                          setTimeout(function() {
                              // $('.editbutton').removeAttr("disabled");
                              // $('.redhighlight').removeAttr("disabled");
                              // $('.normaltext').removeAttr("disabled");
                              $('.deletethis').remove();
                          }, 350);
                          $(id).attr('contenteditable', 'false');
                          edit.attr('contenteditable', 'true');
                          cancel = 0;
                          // console.log('meep');
                      },
                      error: function () {
                          // $('.editbutton')('<p>Failed to Save</p>');
                          console.log('failed');
                      }
                  });
              });
         });
};