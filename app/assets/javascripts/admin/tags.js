$(function(){
  $('#tag_reference').click(function(event){
    event.preventDefault();
    var href = $(this).attr('href');
    $.ajax({
      url: href,
      type: "GET",
      dataType: "html",
      success: function(data, textStatus, xhr){
        $('#popups').append(data);
        Popup.show('tag_reference_popup');
        $('.close_link').click(function(){
          Popup.close();
          $('#tag_reference_popup').remove();
        });
      }
    });
  });

  $("#filter").keyup(function(){

    // Retrieve the input field text and reset the count to zero
    var filter = $(this).val(), count = 0;

    // Loop through the tag list
    $(".tag_description").each(function(){

      // If the list item does not contain the text phrase fade it out
      if ($(this).text().search(new RegExp(filter, "i")) < 0) {
        $(this).fadeOut();

        // Show the list item if the phrase matches and increase the count by 1
      } else {
        $(this).show();
        count++;
      }
    });

    // Update the count
    var numberItems = count;
    $("#filter-count").text("Number of Comments = "+count);
  });
});
