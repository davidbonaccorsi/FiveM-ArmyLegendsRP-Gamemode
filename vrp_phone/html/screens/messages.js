
const predefinedSenders = {
    "2002-2202": "Fleeca Bank",
}

APPS.messages = {
    layout: $(".messages"),
    list: $(".messages > .list"),
    startChatBtn: $(".messages > header > .actions > .new-message"),

    prompt: {
        layout: $(".messages-prompt"),
        confirmBtn: $(".messages-prompt > .confirm"),
        cancelBtn: $(".messages-prompt > header > .actions > .btn"),
        number: $(".messages-prompt > .fields > .box > input"),
        message: $(".messages-prompt > .fields > .box > textarea"),

        show() {
            this.layout.addClass("visible");
        },

        hide() {
            this.layout.removeClass("visible");
        }
    },

    conversation: {
        layout: $(".conversation"),
        backBtn: $(".conversation > header > .actions > .back-to-list"),
        chatList: $(".conversation > .chats"),
        headerNumber: $(".conversation > header > p"),
        gpsBtn: $(".conversation > footer > .actions > .bi-geo-alt"),
        sendBtn: $(".conversation > footer > .actions > .send"),
        message: $(".conversation > footer > input"),

        exit() {
            this.layout.removeClass("visible");
            APPS.messages.layout.addClass("visible");
        },
    },

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

        this.loadMessagesList();
        
    },

    async loadMessagesList() {
        var appData = this;

        appData.list.find(".item").remove();

        let list = await post("getMessagesList");
        
        $.each(list, function(k, v){

            var time = new Date();
            time.setTime(v.time * 1000);

            var date = String(time.getDate()).padStart(2, '0');
            var month = String(time.getMonth()+1).padStart(2, '0');
            var year = time.getFullYear();

            var minutes = String(time.getMinutes()).padStart(2, '0');
            var hour = String(time.getHours()).padStart(2, '0');

            var dateFormat = `${hour}:${minutes} ${date}.${month}.${year}`;

            appData.list.append(`
                <div class="item${v.status ? ' active' : ''}" data-number="${v.number}">
                    
                    <div class="text">
            
                        <header>
                            <p>${(v.name || predefinedSenders[v.number]) ? truncateText(v.name || predefinedSenders[v.number], 10) : v.number}</p>
                            <p>${dateFormat}</p>
                        </header>
            
                        <p>${truncateText(v.msg, 40)}</p>
                        
                    </div>
            
                    <i class="fas fa-chevron-right" aria-hidden="true"></i>
                
                </div>
            `)

        });
    },

    async loadConversation(number){
        var appData = this;

        appData.conversation.headerNumber.text(number);

        var messages = await post("getConversationMessages", [number]);

        appData.conversation.chatList.find(".item").remove();

        var myPhone = phoneNumber.text();

        $.each(messages, function(k, v){

            var time = new Date();
            time.setTime(v.time * 1000);

            var date = String(time.getDate()).padStart(2, '0');
            var month = String(time.getMonth()+1).padStart(2, '0');
            var year = time.getFullYear();

            var minutes = String(time.getMinutes()).padStart(2, '0');
            var hour = String(time.getHours()).padStart(2, '0');

            var dateFormat = `${hour}:${minutes} ${date}.${month}.${year}`;
            
            appData.conversation.chatList.append(`
                
                <div class="item${(v.sender == myPhone) ? ' own' : ''} " ${v.type == 'location' ? 'data-x="'+v.coords[0]+'" data-y="'+v.coords[1]+'"' : ''}>
                    ${v.type == 'location' ? `
                    
                        <div class="location">
                    
                            <i class="bi bi-geo-alt"></i>
                        
                            <div class="text">
                                <p>Shared</p>
                                <p>location</p>
                            </div>
                            
                        </div>

                    ` : `<p>${v.msg}</p>`}
                    <p ${v.type == 'location' ? 'class="date"' : ''}>${dateFormat}</p>
                </div>

            `)

        });

        appData.conversation.chatList.animate({ scrollTop: appData.conversation.chatList.prop("scrollHeight")}, 1000);
    },

    ready() {

        var appData = this;
        appData.startChatBtn.on("click", function(event){
            event.preventDefault();

            appData.prompt.show();

        });

        appData.conversation.chatList.on("click", ".item", function(event){
            event.preventDefault();

            var x = $(this).data("x");
            var y = $(this).data("y");

            if (!x || !y)
                return false;

            Notifications.show("Pozitia a fost setata pe harta!", 2000);
            post("setMapPosition", [x, y]);
        });

        appData.conversation.backBtn.on("click", function(event){
            event.preventDefault();

            appData.conversation.exit();
            appData.loadMessagesList();
        });

        appData.list.on("click", ".item", async function(event){
            event.preventDefault();

            var number = $(this).data("number");
            
            appData.layout.removeClass("visible");

            appData.loadConversation(number);

            appData.conversation.layout.addClass("visible");
        })



        appData.conversation.gpsBtn.on("click", async function(event){
            event.preventDefault();

            var number = appData.conversation.headerNumber.text();

            let coords = await post("getCoordsForMessage");

            post("sendMessage", [number, null, "location", [coords[0], coords[1]]]);

            appData.loadConversation(number);

        });

        appData.conversation.sendBtn.on("click", function(event){
            event.preventDefault();

            var number = appData.conversation.headerNumber.text();
            var message = appData.conversation.message.val();

            if (message.trim().length == 0)
                return false;

            post("sendMessage", [number, message, "message"]);

            appData.conversation.message.val("");

            appData.loadConversation(number);

        });


        appData.conversation.message.on('keyup', function (e) {
            if (e.key === 'Enter' || e.keyCode === 13) {
                
                var number = appData.conversation.headerNumber.text();
                var message = appData.conversation.message.val();
    
                if (message.trim().length == 0)
                    return false;

                post("sendMessage", [number, message, "message"]);
    
                appData.conversation.message.val("");
    
                appData.loadConversation(number);

            }
        });

        appData.prompt.confirmBtn.on("click", function(event){
            event.preventDefault();

            var number = appData.prompt.number.val();
            var message = appData.prompt.message.val();

            if (message.trim().length == 0)
                return false;

            post("sendMessage", [number, message, "message"]);

            setTimeout(() => {
                appData.loadMessagesList();

                appData.loadConversation(number);
                appData.layout.removeClass("visible");
                appData.conversation.layout.addClass("visible");
            }, 1000);

            appData.prompt.hide();

        });

        appData.prompt.cancelBtn.on("click", function(event){
            event.preventDefault();

            appData.prompt.hide();
        })

    }

}

APPS.messages.ready();
