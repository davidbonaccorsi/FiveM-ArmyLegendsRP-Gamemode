
APPS.taxi = {
    layout: $(".taxi"),
    fly: $(".taxi > .box > .fly"),

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

    },

    ready() {
        this.fly.on("click", function(event) {
            event.preventDefault();

            post("callTaxi");
        })
    }

}

APPS.taxi.ready();
