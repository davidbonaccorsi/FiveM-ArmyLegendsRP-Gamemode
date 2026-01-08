
function addNotify(type = "info", time = 5000, title = "Notificare", message) {
  var id = Math.floor(Math.random() * Date.now());

  var sound = new Audio("../public/sounds/notification.mp3");
  sound.volume = 0.4;
  sound.play();

  var escape = (unsafe) => {
    return String(unsafe)
            .replace(/\n/g, '\\n');
    }

  message = escape(message);
  message = message.replace(/\\n/g, "<br>");

  $(".hud-notifications").append(`
    <div class="notification ${type}" id="notification${id}">
      <div class="title">${title}</div>
      <div class="description">${message}</div>
    </div>
  `);
  
  let notification = $(`#notification${id}`);

  setTimeout(() => {
    notification.fadeOut(1000, () => {
      notification.remove();
    });
  }, time);
}
