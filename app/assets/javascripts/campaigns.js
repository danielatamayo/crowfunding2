$(function() {
  $(".fundraiser-image").click(function(){
    $(".img-thumbnail").removeClass("img-selected");
    $("#fundraiser_image").val(this.id);
    $(this).children("img").addClass("img-selected");
  });
});