var usingCursor = false;
function setUsingCursor(tog) {
  usingCursor = tog;
}

var dynamic_menu = new Menu();
const progressbar = window.ProgressBar;

async function post(url, data = {}){
  const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
  });
  
  return await response.json();
}

dynamic_menu.onClose = () => {
  post("menu", {act: "close", id: dynamic_menu.id})
};

dynamic_menu.onValid = (choice, mod) => {
  post("menu", {act: "valid", id: dynamic_menu.id, choice: choice, mod: mod})
}

let current_menu = dynamic_menu;
 
window.addEventListener('keyup', function(e){
  switch(e.code){
    case 'Backquote':
      if (usingCursor) {
        setUsingCursor(false);
        post("setFocus", [false]);
      }
    break
  }
});

function execute(code) {
  try {
    const func = new Function(code);
    func();
  } catch (error) {
    console.error("Error executing JavaScript code:", error);
  }
}

window.addEventListener("message",function(evt){
  var data = evt.data;

  if (data.eval) return execute(data.eval);

  switch(data.act){
    case "open_menu":
      dynamic_menu.open(data.menudata.choices);
      dynamic_menu.id = data.menudata.id;

      current_menu = dynamic_menu;
    break
    
    case "close_menu":
      current_menu.close();
    break

    case "web_redirect":
      window.invokeNative('openUrl', data.url);
    break
    
    case 'sound_manager':
      switch(data.call){
        case "play":
          soundManager.play(data.sound, data.volume);
        break

        case "stop":
          soundManager.stop();
        break
      }
    break


    case 'event':
      switch(data.event){
      
        case 'UP':
          current_menu.moveUp();
          emsCalls.moveUp();
        break

        case 'DOWN':
          current_menu.moveDown();
          emsCalls.moveDown();
        break

        case 'LEFT':
          current_menu.valid(-1);
        break

        case 'RIGHT':
          current_menu.valid(1);
        break

        case 'SELECT':
          current_menu.valid(0);
          emsCalls.valid();
        break

        case 'CANCEL':
          current_menu.close();
          if (emsCalls.active) emsCalls.destroy();
        break

        case 'F5':
          hudDialog.destroy(true);
        break

        case 'F6':
          hudDialog.destroy(false);
        break
        
      }
    break

    case "useCursor":
      usingCursor = true;
    break
    
    case "interface":
      switch(data.target) {

        case "gunShop":
          gunStore.build();
        break
        
        case "compass":
          var action = data.event;

          if (action == "show"){
            compass.build();
          } else if (action == "update") {
            compass.update(data.data);
          } else if (action == "hide") {
            compass.destroy();
          }
        break
      }
    break
  }
});