const playTimeFlips = {
    active: false,
    el: $(".main-playtime-flips"),
    cardList: $(".playtime-flips-flex .card-list"),
    flipping: false,
    
    build() {
        this.active = true;
        $(".main-playtime-flips").fadeIn(1000);
        post("setFocus", [true]);

        this.cardList.find("div").remove();
        this.cardList.removeClass("no-pointer-evs");

        var _this = this;

        for (i=1; i < 4; i++) {

            var card = $(`
                <div data-card="${i}">
                    <img src="">
                    <p></p>
                </div>
            `);

            card.on("click", function() {
                if (_this.flipping) return serverHud.sendError("poti roti o singura carte");

                $(this).addClass("flipping");
                _this.cardList.addClass("no-pointer-evs");
                _this.flipping = parseInt($(this).data("card"));
                post("playtimeflips:rotatingCard");
            })

            this.cardList.append(card);
        }
    },

    winSomething(win, title) {
        var found = this.cardList.find(`[data-card="${this.flipping}"]`);

        found.removeClass("flipping");
        found.addClass("with-prize");
        found.children("img").attr("src", `https://cdn.armylegends.ro/roulette/prizes/${win}.png`);
        found.children("p").text(title);

        this.flipping = false;

        setTimeout(() => {
            this.destroy();
        }, 3500);
    },

    destroy() {
        this.active = false;
        bottomRightHud.cardsFlip = false;
        $(".main-playtime-flips").fadeOut(1000);
        post("setFocus", [false]);
        setUsingCursor(false);
        post("vrp:triggerServerEvent", ["vrp-playtimef:getReminder"]);
    }
}

window.addEventListener("resize", function(event) {
    var zoomCountOne = $(window).width() / 1920;
    var zoomCountTwo = $(window).height() / 1080;
    var zoom = 0;

    if (zoomCountOne < zoomCountTwo) zoom = zoomCountOne;else zoom = zoomCountTwo;

    $(".playtime-flips-flex").css("zoom", zoom);

})

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "playtimeFlips") {
        if (data.event == "show") {
            playTimeFlips.build(data);
        } else if (data.event == "winSomething") {
            playTimeFlips.winSomething(data.win, data.title);
        } else if (data.event == "readyToFlip") {
            var state = true;
            if (data.hide) state = false;

            bottomRightHud.cardsFlip = state;
        } else if (data.event == "reminder") {
            $(".playtime-flips-reminder").fadeIn(1000);
            $(".playtime-flips-reminder > p > span").text(data.flips);
            setTimeout(() => {
                $(".playtime-flips-reminder").fadeOut(1000);
            }, 5000)
        }
    }
});
