
APPS.services = {
    layout: $(".services"),
    list: $(".services > .list"),

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");
        
    },

    ready() {
        this.list.on("click", ".service", function(event){
            event.preventDefault();

            var service = $(this).data("service");

            post("callForService", [service]);
        })
    }
}

APPS.services.ready();
