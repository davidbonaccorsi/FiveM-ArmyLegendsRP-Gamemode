
const lifeInvaderPos = [-590.05615234375,-921.83190917969];

APPS.lifeinvader = {
    layout: $(".lifeinvader"),
    list: $(".lifeinvader > .list"),
    positionBtn: $(".lifeinvader > header > .actions > .position"),

    async build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

        this.list.find(".box").remove();

        var announcements = await post("getAnnouncements");
        var xssID = 0;

        $.each(announcements, function(k,v){
            xssID++;
            
            APPS.lifeinvader.list.prepend(`
            
                    <div class="box">
                        <div class="publicator">
                            <span>Anunt publicat de</span>
                        
                            <div class="user">
                                <i class="bi bi-person"></i>
                                <p>${v.name}</p>
                            </div>

                            <p><i class="bi bi-calendar2-date"></i> ${v.date}</p>
                        </div>

                        <p id="lifeinvader-${xssID}"></p>

                        <div class="call-data">
                            <i class="bi bi-telephone-fill call-publisher" data-phone="${v.phone}"></i>

                            <p>${v.phone}</p>
                        </div>
                    
                    </div>
            
            `);

            $("#lifeinvader-" + xssID).text(truncateText(v.text, 134));

        });

    },

    ready() {
        var appData = this;

        this.list.on("click", ".call-publisher", function(event){
            event.preventDefault();

            var number = $(this).data("phone");

            APPS.goToHome();

            setTimeout(() => {
                APPS.contacts.activeTab = "keys";
                APPS.contacts.keypad.children("h1").text(number);
                APPS.contacts.build();

                APPS.active = "contacts";
            }, 150);

        })

        this.positionBtn.on("click", function(event){
            post("setMapPosition", [lifeInvaderPos[0], lifeInvaderPos[1]]);
            Notifications.show("Pozitia a fost setata pe harta!");
        });
    },

    destroy() {
        this.list.find(".box").remove();
    }

}

APPS.lifeinvader.ready();
