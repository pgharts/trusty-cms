$(document).ready(function() {

  function centeredPopup(url,w,h){
    var popupWindow = null;
    LeftPosition = (screen.width) ? (screen.width-w)/2 : 0;
    TopPosition = (screen.height) ? (screen.height-h)/2 : 0;
    settings =
    'height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition;
    popupWindow = window.open(url,"Share",settings);
  }

  $(".rad-popup-window").click(function(event){
    event.preventDefault();
    var url = $(this).attr("href");
    centeredPopup(url, 625, 430)

  });


});