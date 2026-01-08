
var newGroupTime = false;
window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.job == "newGroup") {
        if (newGroupTime) {
            clearTimeout(newGroupTime);
            $(".newgroup-alert").hide();
        }
    
    
        $(".newgroup-alert").children(".description").children("span").text(data.group);
        $(".newgroup-alert").show();

        // var audio = new Audio("../public/sounds/emssound.mp3");
        // audio.volume = 0.8;
        // audio.play();

        emsTime = setTimeout(() => {
            $(".newgroup-alert").fadeOut(1000);
            emsTime = false;
        }, 3000);
    }
})
