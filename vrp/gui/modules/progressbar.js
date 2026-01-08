

const progressBars = {
    layout: $(".hud-progressbar"),
    percentage: $(".hud-progressbar > p"),
    fill: $(".hud-progressbar .bar .fill"),
    left: 0,

    build(data) {

        this.left = 0;
        this.fill.css("margin-left", "0%");
        this.layout.fadeIn();

        var addition = 10 / data.duration * 100;
      
        var interval = setInterval(() => {
          if (this.left >= 100) {
            clearInterval(interval);
            
            this.layout.fadeOut();
            post("progressBars:end");

          } else {
            this.left += addition;
            var value = Math.floor(this.left);

            this.fill.css("margin-left", `${value}%`);
            this.percentage.text(`${data.title} ${value}%`)
          }
        }, 10);

    }

}


window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "progressBars"){
        progressBars.build(data.data);
    }
});
