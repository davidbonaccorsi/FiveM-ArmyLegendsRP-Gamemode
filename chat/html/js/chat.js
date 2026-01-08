
async function post(url, data = {}) {
    const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
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


const chat = {
    container: $('.chat-posts'),
    input: $(".chat-hud-input"),
    hiddenActions: $('.chat-actions-hidden'),
    fastActionsBtn: $("#main-action"),

    size: 0,
    direction: "upToDown", // upToDown, downToUp
    active: false,
    forcedToHide: false,
    timer: null,
    timerPush: null,
    oldMessages: [],
    oldMessagesIndex: -1,

    build(hideInput) {
        this.active = true;
        clearTimeout(this.timer);
        clearTimeout(this.timerPush);

        if (!this.forcedToHide) {
            $("#chat").animate({opacity: 1}, 500);
            $(".chat-posts").css("overflow",'overlay');
        }

        if (!hideInput) {
            this.showFooter();
            this.input.focus();
        } else {
            this.hideFooter();
        }
    },

    queueHide() {
    	clearTimeout(this.timer);
    	clearTimeout(this.timerPush);
        
        this.timerPush = setTimeout(function () {
            chat.hide();
            $(".chat-posts").css("overflow",'hidden');
        }, 10000);
    },

    escape(unsafe) {
        return String(unsafe)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;')
                .replace(/\n/g, '\\n');
    },

    colorize(str) {

        str = this.escape(str);


        let s = "<strong>" + (str.replace(/\^([0-9a-z])/g, (str, color) => `</strong><strong class="color-${color}">`)) + "</strong>";
  
        // Detect HEX colors in the format "#{hex}"
        s = "<strong>" + (s.replace(/#\{(\w+)\}/g, (str, color) => `</strong><strong style="color:#${color};">`)) + "</strong>";

        // Detect RGB colors in the format "#rgb[r,g,b]"
        s = "<strong>" + (s.replace(/#rgb\[(\d+,\d+,\d+)\]/g, (str, color) => `</strong><strong style="color:rgb(${color});">`)) + "</strong>";

        const elementsDict = {
            '*': 'strong',
        };
    
        const emtsRegex = /\^(\_|\*|\=|\~|\/|r)(.*?)(?=$|\^r|<\/em>)/;
        while (s.match(emtsRegex)) {
            s = s.replace(emtsRegex, (str, foundEm, inner) => `<${elementsDict[foundEm]}>${inner}</${elementsDict[foundEm]}>`)
        }

        s = s.replace(/\\n/g, "<br>");

        s = s.replace(/<strong[^>]*><\/strong[^>]*>/g, '');
        
        return s;
    },

    moveOldMessageIndex(up) {
        if (up && this.oldMessages.length > this.oldMessagesIndex + 1) {
          this.oldMessagesIndex += 1;
          this.input.val(this.oldMessages[this.oldMessagesIndex])
        } else if (!up && this.oldMessagesIndex - 1 >= 0) {
          this.oldMessagesIndex -= 1;
          this.input.val(this.oldMessages[this.oldMessagesIndex])
        } else if (!up && this.oldMessagesIndex - 1 === -1) {
          this.oldMessagesIndex = -1;
          this.input.val("");
        }
    },

    clear() {
        this.container.find(".chat-post").remove();
        this.oldMessages = [];
        this.oldMessagesIndex = -1;
    },

    hideFooter() {
        $(".chat-hidden").hide();
    },

    showFooter() {
        $(".chat-hidden").show();
    },

    addMessage(msg, type = "msg") {
        if (!this.active){
            this.build(true);
            this.queueHide();
        }

        if (type == "msg") {
            msg = this.colorize(msg);
            // tag fondator
            msg = msg.replace(/<strong style="color:#c25050;">Fondator/g, `<strong style="color:#c25050;" class="chat-ico-fondator chat-ico-staffbox chat-ico-relative">Fondator`);

            // Manager tag
            msg = msg.replace(/<strong style="color:#ffa500;">Manager/g, `<strong style="color:#ffa500;" class="chat-ico-manager chat-ico-staffbox chat-ico-relative">Manager`);

            // tag supervizor
            msg = msg.replace(/<strong style="color:#ffff00;">Supervizor/g, `<strong style="color:#ffff00;" class="chat-ico-supervizor chat-ico-staffbox chat-ico-relative">Supervizor`);

            // tag administrator
            msg = msg.replace(/<strong style="color:#008000;">Administrator/g, `<strong style="color:#008000;" class="chat-ico-administrator chat-ico-staffbox chat-ico-relative">Administrator`);

            // tag moderator
            msg = msg.replace(/<strong style="color:#0027ff;">Moderator/g, `<strong style="color:#0027ff;" class="chat-ico-moderator chat-ico-staffbox chat-ico-relative">Moderator`);

            // tag helper
            msg = msg.replace(/<strong style="color:#b700ff;">Helper/g, `<strong style="color:#b700ff;" class="chat-ico-helper chat-ico-staffbox chat-ico-relative">Helper`);

            // tag trialhelper
            msg = msg.replace(/<strong style="color:#808080;">Trial Helper/g, `<strong style="color:#808080;" class="chat-ico-trialhelper chat-ico-staffbox chat-ico-relative">Trial Helper`);

            this.container[this.direction == "upToDown" ? "append" : "prepend"](`
                <div class="chat-post">${msg}</div>
            `)
        } else if (type == "info") {

            this.container[this.direction == "upToDown" ? "append" : "prepend"](`
                <div class="chat-post smi-ad heart">
                    <span><img src="https://cdn.armylegends.ro/chat/info.svg"></span>
                    <div class = "chat-smi-wrap">
                        <span>${msg[1]}</span>
                        <span>
                            ${msg[2]}
                        </span>
                    </div>
                </div>
            `);
        }

        this.container.animate({ scrollTop: this.container.prop("scrollHeight")}, 1000);
    },

    destroy() {
        this.active = false;
        this.hideFooter();
        clearTimeout(this.timer);
        clearTimeout(this.timerPush);
        
        this.timer = setTimeout(function () {
            chat.hide();
            $(".chat-posts").css("overflow",'hidden');
        }, 10000);

        post("setFocus", [false]);
    },

    hide() {
        this.active = false;
        $("#chat").animate({ opacity: 0}, 1000)
    },

    ready() {
        var $this = this;

        $this.input.on('keydown', function (e) {
            if (e.key === 'Enter' || e.keyCode === 13) {
                
                var message = $this.input.val();
    
                if (message.trim().length == 0)
                    return $this.destroy();
                
                $this.input.val("");
                $('#chat-me').prop('checked', true);

                post("chatResult", [message]);

                $this.oldMessages.unshift(message);
                $this.oldMessagesIndex = -1;

                $this.destroy();

            } else if (e.which === 38 || e.which === 40) {
                e.preventDefault();
                $this.moveOldMessageIndex(e.which === 38);
            }
        });

        // this.clear();
        this.hideFooter();
        this.destroy();
        this.hide();
    }
    
}

chat.ready();

var minimumWidth = 1920;
var minimumHeigh = 1080;
window.onload = function(){
    changeSizeWidth();
    $(window).resize(changeSizeWidth);
}
function changeSizeWidth() 
{
    
    var zoomCountOne = $(window).width() / minimumWidth;
    var zoomCountTwo = $(window).height() / minimumHeigh;
    
    if(zoomCountOne < zoomCountTwo) 
    {
        $('.main-chat-wrap').css('zoom', zoomCountOne);
    }
    else {
        $('.main-chat-wrap').css('zoom', zoomCountTwo);
    }
}

// $( "#main-action" ).click(function() {
//     if($(".chat-actions-hidden" ).is(':visible')) {
//         chat.hiddenActions.fadeOut();
//         chat.fastActionsBtn.removeClass("opacity");
//     }
//     else 
//     {
//         chat.hiddenActions.fadeIn();
//         chat.fastActionsBtn.addClass("opacity");
//     }
// });

$(".chat-hud-action").on('click', 'input', function(event) {
    event.preventDefault();

    let autoTexts = {
        "chat-me": "/me ",
        "chat-try": "/me Incearca sa ",
        "chat-do": "/me Face ",
        "chat-todo": "/me Trebuie sa faca "
    };

    var btn = $(this).val();
    if (!autoTexts[btn]) return;

    chat.input.val(autoTexts[btn]);
    chat.input.focus();
});

window.addEventListener("keydown", function(event) {
    if (event.code == "Escape" && chat.active){
        chat.destroy();
        chat.input.val("");
    }
})

window.addEventListener("message", function(event) {
    event.preventDefault();
    const data = event.data;

    if (data.act == "build") {
        chat.build();
    } else if (data.act == "clear") {
        chat.clear();
    } else if (data.act == "onMessage") {
        chat.addMessage(data.msg, data.type);
    } else if (data.act == "onComponentDisplaySet") {
        chat.forcedToHide = !data.tog;

        if (chat.forcedToHide) chat.hide();
    }
})
