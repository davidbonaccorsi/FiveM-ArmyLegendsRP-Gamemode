var KeyPress = new CircleProgress(".key-press-progress");
KeyPress.max = 100;
KeyPress.value = 0;
KeyPress.textFormat = "none";

window.addEventListener("message", function (evt) {
  let data = evt.data;
  switch (data.action) {
    case "openKeyPress":
      KeyPress.value = 0;
      KeyPress.textFormat = function (value, max) {
        return data.tasta;
      };
      $(".key-press").fadeIn();
      break;
    case "updateKeyPress":
      KeyPress.value = data.value;
    break;
    case "closeKeyPress":
      $(".key-press").fadeOut();
      break;

    case "colorizeMicrophone":
      $("#microfon").css("opacity", data.talking ? "1" : "0.5")
    break
  }
});
