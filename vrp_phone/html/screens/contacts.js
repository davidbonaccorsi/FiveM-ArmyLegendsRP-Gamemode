
APPS.contacts = {
    layout: $(".contacts"),
    tabs: $(".contacts > footer"),
    activeTab: "contacts-list",

    plusBtn: $(".contacts > header > .actions > .plus"),
    trashBtn: $(".contacts > header > .actions > .trash"),

    contactsList: $(".contacts > .contacts-list"),
    callsList: $(".contacts > .calls-list"),
    sharedList: $(".contacts > .shared-list"),
    keypad: $(".contacts > .keypad"),

    createPrompt: {
        layout: $(".contacts-prompt.add-contact"),
        confirmBtn: $(".contacts-prompt.add-contact > .confirm"),
        cancelBtn: $(".contacts-prompt.add-contact > header > .actions > .btn"),
        name: $(".contacts-prompt.add-contact > .fields > .box:first-of-type > input"),
        number: $(".contacts-prompt.add-contact > .fields > .box:last-of-type > input"),

        show() {
            this.layout.addClass("visible");
        },

        hide() {
            this.layout.removeClass("visible");
        }
    },

    editPrompt: {
        layout: $(".contacts-prompt.edit-contact"),
        confirmBtn: $(".contacts-prompt.edit-contact > .confirm"),
        cancelBtn: $(".contacts-prompt.edit-contact > header > .actions > .btn"),
        name: $(".contacts-prompt.edit-contact > .fields > .box:first-of-type > input"),
        number: $(".contacts-prompt.edit-contact > .fields > .box:last-of-type > input"),

        lastData: [],

        show() {
            this.layout.addClass("visible");
            this.number.val("");
            this.name.val("");
        },

        hide() {
            this.layout.removeClass("visible");
        }
    },

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");
        
        this.loadPage();
    
    },

    async loadPage() {

        var appData = this;

        appData.tabs.find("[data-tab]").removeClass("active");
        appData.tabs.find(`[data-tab='${appData.activeTab}']`).addClass("active");

        appData.layout.find("[data-page]").removeClass("visible");
        appData.layout.find(`[data-page='${appData.activeTab}']`).addClass("visible");

        if (appData.activeTab == "contacts-list"){
            appData.trashBtn.addClass("hidden");
            appData.plusBtn.removeClass("hidden");

            appData.contactsList.find(".contact").remove();

            let contacts = await post("getContactsList");
            
            $.each(contacts, function(k, v){
                
                appData.contactsList.append(`

                    <div class="contact" data-number="${k}" data-name="${v.name}">
                        <i class="bi bi-person-fill"></i>
                    
                        <div class="data">
                            <p>${v.name}</p>
                            <p>${k}</p>
                        </div>

                        <div class="actions">
                            
                            <div class="action tooltip" title="Suna" data-act="call">
                                <i class="fa-solid fa-phone"></i>
                            </div>

                            <div class="action tooltip" title="Scrie un mesaj" data-act="message">
                                <i class="fas fa-message" aria-hidden="true"></i>
                            </div>

                            <div class="action tooltip" title="Editeaza contact" data-act="edit">
                                <i class="fa-solid fa-pencil"></i>
                            </div>

                            <div class="action tooltip" title="Sterge contact" data-act="delete">
                                <i class="fa-solid fa-trash"></i>
                            </div>
                                        
                        </div>
                    </div>
                
                `);

                appData.contactsList.find('[data-number="'+k+'"]').find('.tooltip').tooltipster({
                    animation: 'grow',
                    delay: 0,
                    theme: "tooltipster-borderless"
                });

            });
            
        } else if (appData.activeTab == "calls") {
            appData.trashBtn.addClass("hidden");
            appData.plusBtn.addClass("hidden");

            appData.callsList.find(".call").remove();

            var calls = await post("getLastCalls");
            
            $.each(calls, function(k, v){

                appData.callsList.append(`
                
                    <div class="call" data-number="${v}">
                        <p>${v}</p>
                    
                        <div class="call-box">
                            <i class="fa-solid fa-phone-volume"></i>
                        </div>
                    </div>

                `)

            })

        } else if (appData.activeTab == "shared") {
            appData.trashBtn.addClass("hidden");
            appData.plusBtn.addClass("hidden");

            appData.sharedList.find(".box").remove();

            var list = await post("getSharedContacts");
            
            $.each(list, function(k, v){

                appData.sharedList.append(`
                
                    <div class="box" data-number="${k}" data-name="${v}">
                        <div class="text">
                            <p>${v}</p>
                            <p>${k}</p>
                        </div>
                    
                        <div class="add-box">
                            <i class="fa-solid fa-user-plus"></i>
                        </div>
                    </div>

                `)

            })

        } else if (appData.activeTab == "keys") {
            appData.trashBtn.addClass("hidden");
            appData.plusBtn.addClass("hidden");
        }

    },

    async callNumber(number) {
        let response = await post("callNumber", [number]);

        if (!response)
            return Notifications.show("Nu te poti apela singur!");
        
        if (response.inCall)
            return Notifications.show("Esti deja intr-un apel!");

        if (!response.available)
            return Notifications.show("Persoana apelata e indisponibila!");

        callDisplay.show(undefined, response.contact || number, true);

    },

    ready() {
        
        var appData = this;
        appData.plusBtn.on("click", function(event) {
            event.preventDefault();

            appData.createPrompt.show();
        });

        appData.tabs.on("click", ".tab", function(event){
            event.preventDefault();
            
            var tab = $(this).data("tab");

            appData.activeTab = tab;

            appData.loadPage();
        });


        appData.callsList.on("click", ".call > .call-box", function(event){
            event.preventDefault();

            var parentObj = $(this).parent();
            var number = parentObj.data("number");

            appData.callNumber(number);
        });

        appData.sharedList.on("click", ".box > .add-box", async function(event){
            event.preventDefault();

            var parentObj = $(this).parent();
            var number = parentObj.data("number");
            var name = parentObj.data("name");
            
            appData.createPrompt.show();
            appData.createPrompt.name.val(name);
            appData.createPrompt.number.val(number);

            let ok = await post("deleteSuggestedContact", [number]);
            appData.loadPage();
        });

        appData.keypad.on("click", ".key", function(event){
            event.preventDefault();

            var key = $(this).data("key");
            var number = appData.keypad.children("h1");
            var value = number.text();

            if (key == "*"){
                number.text(value.substr(0, value.length - 1));
            } else {
                number.text(value + key);
            }

        });

        appData.keypad.on("click", ".call-box", function(event){
            event.preventDefault();

            var value = appData.keypad.children("h1").text();

            if (value.length < 3)
                return false;
            
            appData.callNumber(value);
        });

        appData.contactsList.on("click", ".contact > .actions > .action", async function(event){
            event.preventDefault();

            var act = $(this).data("act");
            var contactObj = $(this).parent().parent();
            var number = contactObj.data("number");
            var name = contactObj.data("name");

            if (act == "call"){
                appData.callNumber(number);
            } else if (act == "message"){
                let known = await post("hasAnyMsgWithContact", [number]);

                APPS.goToHome();

                setTimeout(() => {
                    if (known){
                        APPS.home.layout.removeClass("visible");
                        
                        APPS.messages.loadConversation(number);
            
                        APPS.messages.conversation.layout.addClass("visible");
                    
                    } else {
                        APPS.messages.build();

                        APPS.messages.prompt.number.val(number);
                        APPS.messages.prompt.message.val("");
                        APPS.messages.prompt.show();
                    }

                    APPS.active = "messages";
                }, 100);

            } else if (act == "edit"){

                appData.editPrompt.show();

                appData.editPrompt.lastData = [name, number];

                appData.editPrompt.name.val(name);
                appData.editPrompt.number.val(number);
                
            } else if (act == "delete"){
                let ok = await post("deleteContact", [number]);
            
                if (!ok)
                    return false;
    
                appData.loadPage();
            }
        });

        appData.editPrompt.confirmBtn.on("click", async function(event) {
            event.preventDefault();

            var lastData = appData.editPrompt.lastData;

            var name = appData.editPrompt.name.val();
            var number = appData.editPrompt.number.val();

            if (name.length < 2)
                return false;

            if (number.length < 4)
                return false;

            var modifiedOne = (name != lastData[0]) || (number != lastData[1]);

            if (!modifiedOne)
                return false;

            let ok = await post("editContact", [lastData, name, number]);
            
            if (!ok)
                return false;

            appData.editPrompt.hide();
            appData.loadPage();
        });

        appData.createPrompt.confirmBtn.on("click", async function(event) {
            event.preventDefault();

            var name = appData.createPrompt.name.val();
            var number = appData.createPrompt.number.val();

            if (name.length < 2)
                return false;

            if (number.length < 4)
                return false;

            let ok = await post("addNewContact", [name, number]);
            
            if (!ok)
                return false;

            appData.createPrompt.hide();
            appData.loadPage();
        });

        appData.editPrompt.cancelBtn.on("click", function(event) {
            event.preventDefault();

            appData.editPrompt.hide();
        });

        appData.createPrompt.cancelBtn.on("click", function(event) {
            event.preventDefault();

            appData.createPrompt.hide();
        });

        
    }

}

APPS.contacts.ready();
