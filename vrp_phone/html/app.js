// init tooltipster
$('.tooltip').tooltipster({
    animation: 'grow',
    delay: 0,
    theme: "tooltipster-borderless"
});

async function post(url, data = {}, res = GetParentResourceName()) {
    const response = await fetch(`https://${res}/${url}`, {
        method: 'POST',
        mode: 'no-cors',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });

    return await response.json();
}

const truncateText = (text, max) => {
    return text.substr(0,max-1)+(text.length>max?'...':''); 
}

const phoneLayout = $(".phone-layout");
const APPS = {};

const Notifications = {
    element: $(".notification"),
    description: $(".notification > .text > p"),
    timeout: false,
    
    show(text, time = 5000, phoneOn = true) {
        if (!phoneOn){
            phoneLayout.css("bottom", "-45%");
            phoneLayout.css("opacity", "0");
            phoneLayout.addClass("only-notify");
            phoneLayout.addClass("visible");
            phoneLayout.animate({
                bottom: "-35%",
                opacity: 1
            }, 1500)
        }

        if (this.timeout){
            this.element.removeClass("visible");
            clearTimeout(this.timeout);
        }

        if (!APPS.settings.dndMode){
            var sound = new Audio("system/notification.ogg");
            sound.volume = 0.1;
            sound.play();
        }

        this.description.text(text);

        this.element.addClass("visible");

        this.timeout = setTimeout(() => {
            this.destroy();
            this.timeout = false;

            if (!phoneOn){
                phoneLayout.removeClass("visible");
                phoneLayout.removeClass("only-notify");
                phoneLayout.css("bottom", "0");
            }
        }, time);
    },

    destroy() {
        this.element.removeClass("visible");
    },

    ready() {
        var $this = this;
        this.element.on("click", function(event){
            if ($this.timeout){
                $this.element.removeClass("visible");
                clearTimeout($this.timeout);
            }
        })
    }
}

Notifications.ready();

const callDisplay = {
    element: $(".call-display"),
    state: $(".call-display > .text > p:first-of-type"),
    name: $(".call-display > .text > p:last-of-type"),
    okBtn: $(".call-display > .actions > .action.ok"),
    endBtn: $(".call-display > .actions > .action.end"),

    active: false,
    caller: false,

    statesText: {
        "dialing": "Apelezi...",
        "in-call": "In apel cu",
        "being-called": "Esti sunat",
    },

    show(state = "dialing", name = "Unknown", caller) {

        this.element.addClass("visible");

        this.caller = caller;

        this.state.text(this.statesText[state]);
        this.name.text(truncateText(name, 16));

        (state == "being-called") ? this.okBtn.removeClass("hidden") : this.okBtn.addClass("hidden");

        this.active = state;

    },

    update(state) {
        this.state.text(this.statesText[state]);

        if (!this.okBtn.hasClass("hidden"))
            return this.okBtn.addClass("hidden");
    },

    destroy() {
        this.element.removeClass("visible");
        this.active = false;
        this.caller = false;
    },

    ready() {

        var appData = this;

        this.okBtn.on("click", function(event){
            post("acceptCall");
        });

        this.endBtn.on("click", function(event){
            appData.destroy();
            post("endCurrentCall");
        });

    }
};

callDisplay.ready();

const smsNotify = {
    element: $(".sms-notify"),
    number: $(".sms-notify > .content > .header > span"),
    message: $(".sms-notify > .content > .sms-text"),
    timeout: false,

    show(number, msg) {
        if (this.timeout){
            this.element.removeClass("visible");
            clearTimeout(this.timeout);
        }

        if (!APPS.settings.dndMode){
            var sound = new Audio("system/sms.ogg");
            sound.volume = 0.1;
            sound.play();
        }

        this.number.text(predefinedSenders[number] || number);
        this.message.text(truncateText(msg, 38));

        this.element.addClass("visible");

        this.timeout = setTimeout(() => {
            this.destroy();
            this.timeout = false;
        }, 5000);
    },

    destroy() {
        this.element.removeClass("visible");
    }
}

const timeEmt = $(".home > h1");

const updateTime = () => {

    var date = new Date();
    var minutes = String(date.getMinutes()).padStart(2, '0');
    var hour = String(date.getHours()).padStart(2, '0');
  
    timeEmt.text(`${hour}:${minutes}`);

    setTimeout(updateTime, 60000);
};
updateTime();

const closePhone = () => {
    $('.tooltip').tooltipster('hide');

    phoneLayout.animate({
        opacity: 0,
    }, 500, function() {
        phoneLayout.removeClass("visible");
        phoneLayout.css("opacity", "1");
        post("closePhone");
    });

    post("setFocus", [false]);
};

window.addEventListener("keydown", function(event){
    var theKey = event.code;

    if (theKey == "Escape"){
        closePhone();
    }
})

$(document).on("mousedown", function(data) {
	if (data.which == 3)
        return post("setFocus", [false]);
});

const phoneNumber = $(".home > .your-number > .number-field > p");

var ringerAudioHnd = false;
var dialingAudioHnd = false;

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.act == "build"){
        var loadData = data.data;

        APPS.settings.wallpaper = loadData.splash;
        APPS.settings.refreshWallpaper();

        APPS.settings.ringer = loadData.ringer;
        APPS.settings.ringerLayout.children("p").text(ringerSounds[APPS.settings.ringer-1]);

        phoneNumber.text(loadData.number);

        phoneLayout.addClass("visible");

        if (Notifications.timeout){
            clearTimeout(Notifications.timeout);
            Notifications.timeout = false;
            Notifications.destroy();

            phoneLayout.removeClass("only-notify");
            phoneLayout.animate({
                bottom: 0,
            }, 1000)
        }

        if (APPS.messages.conversation.layout.hasClass("visible")){
            APPS.messages.conversation.chatList.animate({ scrollTop: APPS.messages.conversation.chatList.prop("scrollHeight")}, 1000)
        }

        post("setFocus", [true]);
    } else if (data.act == "notify"){

        Notifications.show(data.msg, data.time, data.phoneOn)

    } else if (data.act == "setNumber"){
        phoneNumber.text(data.number);
        APPS.banking.iban.text(data.iban);
    } else if (data.act == "refreshShareFeed") {
        APPS.ishare.loadFeed();
    } else if (data.act == "refreshConversation") {
        var number = APPS.messages.conversation.headerNumber.text();

        if (number != data.number)
            return false;

        if (!APPS.messages.conversation.layout.hasClass("visible"))
            return false;

        APPS.messages.loadConversation(number);
    } else if (data.act == "smsNotify") {

        if (phoneLayout.hasClass("visible") && !APPS.messages.conversation.layout.hasClass("visible") && APPS.messages.layout.hasClass("visible"))
            return APPS.messages.loadMessagesList();

        if (phoneLayout.hasClass("visible") && APPS.messages.conversation.layout.hasClass("visible") && APPS.messages.conversation.headerNumber.text() == data.number)
            return false;

        smsNotify.show(data.number, data.msg);
    } else if (data.act == "getCalled") {
        callDisplay.show("being-called", data.contact || data.number, false);
    } else if (data.act == "cancelCallDisplay") {
        callDisplay.destroy();
        
        if (dialingAudioHnd){
            dialingAudioHnd.pause();
            dialingAudioHnd = false;
        }

        if (ringerAudioHnd){
            ringerAudioHnd.pause();
            ringerAudioHnd = false;
        }

    } else if (data.act == "playRingerSound") {

        if (ringerAudioHnd){
            ringerAudioHnd.pause();
            ringerAudioHnd = false;
        }

        var sound = new Audio(`system/ringtones/${APPS.settings.ringer}.ogg`);
        sound.volume = 0.2;
        sound.play();

        ringerAudioHnd = sound;

    } else if (data.act == "playDialingSound") {

        if (dialingAudioHnd){
            dialingAudioHnd.pause();
            dialingAudioHnd = false;
        }

        var sound = new Audio(`system/dialing.ogg`);
        sound.volume = 0.155;
        sound.play();

        dialingAudioHnd = sound;
    } else if (data.act == "setCallDisplayAsAnswered") {
        callDisplay.update("in-call");

        if (dialingAudioHnd){
            dialingAudioHnd.pause();
            dialingAudioHnd = false;
        }

        if (ringerAudioHnd){
            ringerAudioHnd.pause();
            ringerAudioHnd = false;
        }
    } else if (data.act == "setMapState") {
        data.toggle ? smsNotify.element.addClass("map-active") : smsNotify.element.removeClass("map-active");
    }

})
