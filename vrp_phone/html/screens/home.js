
const onlyClientApps = {"camera": true, "shop": true};

APPS.home = {

    layout: $(".home"),
    appsList: $(".apps-list"),
    shareContact: $(".home > .your-number >.suggest-contact"),

    ready() {
        this.shareContact.on("click", function(event) {
            event.preventDefault();
            post("suggestContact");
        })
    },

};

APPS.home.ready();

APPS.home.appsList.on("click", ".app-icon", function(event){
    event.preventDefault();
    var app = $(this).data('app');

    if (!app)
        return false;

    if (!APPS[app] || typeof(APPS[app].build) != "function")
        return Notifications.show("Aplicatia este indisponibila.", 3500);

    APPS[app].build();

    if (onlyClientApps[app])
        return false;

    APPS.active = app;
});

APPS.goToHome = () => {
    var currentApp = APPS[APPS.active];

    if (!currentApp)
        return false;

    if (currentApp.destroy){
        currentApp.destroy();
    }

    if (currentApp.layout && currentApp.layout.hasClass("visible")){
        currentApp.layout.removeClass("visible");
        APPS.home.layout.addClass("visible");
    }
}

$(".exit-to-home").on("click", function(event){
    event.preventDefault();
    APPS.goToHome();
})
