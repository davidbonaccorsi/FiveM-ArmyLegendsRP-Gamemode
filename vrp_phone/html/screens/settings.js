
const ringerSounds = ["SUNET 1", "SUNET 2", "SUNET 3"];

APPS.settings = {
    layout: $(".settings"),
    ringerLayout: $(".settings").children("main").children(".ringer-selector").children(".selector"),
    splashLayout: $(".settings").children("main").children(".splash-selector").children(".list"),
    dndModeLayout: $(".settings").children("main").children(".dnd-mode"),

    ringer: 3,
    wallpaper: 2,
    dndMode: false,
    ringerAudio: false,

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

    },

    refreshWallpaper() {
        $(":root").css("--wallpaper", `url("https://cdn.armylegends.ro/phone/newphone_wallpaper_${this.wallpaper}.png")`);
    },

    async ready() {
        this.dndModeLayout.on("click", ".switcher", function(event){
            event.preventDefault();
            var checkBtn = $(this).children(".check");

            checkBtn.toggleClass("checked");
            
            APPS.settings.dndMode = checkBtn.hasClass("checked");
        });

        this.ringerLayout.on("click", "i", function(event){
            event.preventDefault();
            var direction = $(this).data("direction");
            var ringer = APPS.settings.ringer;
            var modifiedOne = false;

            if (direction == "next"){
                APPS.settings.ringer = ringer + 1 > ringerSounds.length ? 1 : ringer + 1;
                modifiedOne = true;
            } else if (direction == "prev") {
                APPS.settings.ringer = ringer - 1 < 1 ? ringerSounds.length : ringer - 1;
                modifiedOne = true;
            } else {

                if (APPS.settings.ringerAudio){
                    APPS.settings.ringerAudio.pause();
                    APPS.settings.ringerAudio = false;
                }

                var sound = new Audio(`system/ringtones/${ringer}.ogg`);
                sound.volume = 0.095;
                sound.play();

                APPS.settings.ringerAudio = sound;

            }
        
            if (modifiedOne) {
                APPS.settings.ringerLayout.children("p").text(ringerSounds[APPS.settings.ringer-1])
                post("setRingerSound", [APPS.settings.ringer]);
            }
        });

        this.splashLayout.on("click", ".item", function(event){
            event.preventDefault();
            var wallpaper = $(this).data("wallpaper");

            APPS.settings.wallpaper = wallpaper;
            APPS.settings.refreshWallpaper();

            post("setWallpaper", [APPS.settings.wallpaper]);
        });


        this.refreshWallpaper();

    },

};

APPS.settings.ready();
