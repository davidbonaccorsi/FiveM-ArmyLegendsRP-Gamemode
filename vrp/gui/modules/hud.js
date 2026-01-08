
const compass = new Vue({
    el: ".compass-layout",
    data: {
        active: false,
        district: "",
        street: "",
        cardinal: "N",
    },
    methods: {
        build() {
            this.active = true;
            $(".compass-layout").fadeIn("fast");
        },

        getCardinalPoint(heading) {
            const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
            return points[Math.round(((heading % 360) / 45)) % 8];
        },

        update(data) {
            if (data.heading) {
                this.cardinal = this.getCardinalPoint(data.heading);
            } else {
                this.district = data.district;
                this.street = data.street;
            }
        },

        destroy() {
            this.active = false;
            $(".compass-layout").fadeOut();
        },
    },
})

const rpmLineElements = {
    9: 'speedometer_animLine_9',
    8: 'speedometer_animLine_8',
    7: 'speedometer_animLine_7',
    6: 'speedometer_animLine_6',
    5: 'speedometer_animLine_5',
    4: 'speedometer_animLine_4',
    3: 'speedometer_animLine_3',
    2: 'speedometer_animLine_2',
    1: 'speedometer_animLine_1',
}

const rpmElements = {
    8: 'speedometer_anim_8',
    7: 'speedometer_anim_7',
    6: 'speedometer_anim_6',
    5: 'speedometer_anim_5',
    4: 'speedometer_anim_4',
    3: 'speedometer_anim_3',
    2: 'speedometer_anim_2',
    1: 'speedometer_anim_1',
}

const rpmNumberElements = {
    9: 'speedometer_animNumber_9',
    8: 'speedometer_animNumber_8',
    7: 'speedometer_animNumber_7',
    6: 'speedometer_animNumber_6',
    5: 'speedometer_animNumber_5',
    4: 'speedometer_animNumber_4',
    3: 'speedometer_animNumber_3',
    2: 'speedometer_animNumber_2',
    1: 'speedometer_animNumber_1',
    0: 'speedometer_animNumber_0',
}


const serverHud = new Vue({
    el: ".hud-top-right",
    data: {
        zoom: 0,
        show: true,

        errortime: false,
        infotime: false,

        id: "0",
        online: 0,

        wanted: 0,

        weapon: false,

        safezone: false,


        beginner_show: true,
        beginner_timeout: false,
        beginner_quests: [],


        announce_phone: "",
        announce_name: "",
        announce_msg: "",
        announce_show: false,

        jail_show: false,
        jail_time: "23m 50s",

        radio_codes: false,

        hint_notify: false,
        hint_notify_svg: false,
        hint_notify_title: "",
        hint_notify_text: "",
        hint_notify_icon: "",

        achieve_notify: false,
        achieve_notify_complete: false,
        achieve_notify_title: "",
        achieve_notify_text: "",
        achieve_notify_progress: 0,
        achieve_notify_task: 0,
    },
    mounted() {
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("message", this.onMessage)
    },
    methods: {
        
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        formatString: function(str, ...args) {
            return str.replace(/{(\d+)}/g, (match, index) => args[index] || "");
        },

        onMessage() {
            const data = event.data;

             if (data.interface == "setHudId") {
                this.id = data.id;
            } else if (data.interface == "setHudPlayers") {
                this.online = data.players;
            } else if (data.interface == "setHudWanted") {
                this.wanted = data.wanted;
            } else if (data.interface == "setHudWeapon") {
                this.weapon = data.weapon;
            } else if (data.interface == 'updateHudWeapon') {
                if (this.weapon) {
                    this.weapon.load = data.ammo;
                }
            } else if (data.action == "setComponentDisplay") {

                if (data.component == "*") {
                    for (const [key, value] of Object.entries(globalThis.uiComponents)) {
                        value.show = data.tog;
                    }
                } else {
                    
                    if (!globalThis.uiComponents[data.component]) return false;

                    globalThis.uiComponents[data.component].show = data.tog;
                }
            } else if (data.interface == "beginnerQuest") {
                if (data.event == "show") {
                    this.beginner_quests = data.quests;
                    this.beginner_show = true;
                } else if (data.event == "complete") {
                    var el = $(".beginner-complete");
                    // this.beginner_show = false;

                    if (this.beginner_timeout) {
                        clearTimeout(this.beginner_timeout);
                        el.hide();
                    }

                    el.children("p").children("span").children("span").text(data.quest);
                    el.show();

                    this.beginner_timeout = setTimeout(() => {
                        el.hide();
                        this.beginner_timeout = false;
                    }, 5000);

                } else if (data.event == "hide") {
                    this.beginner_show = false;
                }
            } else if (data.interface == "safezone") {
                this.safezone = data.show;
            } else if (data.interface == "lifeInvaderPost") {
                this.announce_name = this.truncateText(data.data.name, 20);;
                this.announce_phone = data.data.phone;
                this.announce_msg = data.data.msg;
                this.announce_show = true;

                setTimeout(() => {
                    this.announce_show = false;
                }, 15000);
            } else if (data.interface == "headbag") {
                $(".headbag")[data.tog ? "show" : "hide"]();
            } else if (data.interface == "hintNotify") {
                let time = 5000;
                var id = Math.floor(Math.random() * Date.now());

                var audio = new Audio("../public/sounds/hint.ogg")
                audio.volume = 0.5;
                audio.play();

                var escape = (unsafe) => {
                    return String(unsafe)
                            .replace(/\n/g, '\\n');
                    }
                
                let text = escape(data.text);
                text = text.replace(/\\n/g, "<br>");

                $('.hint-notify-wrapper').append(`
                    <div class="hint-notify" id='hint${id}'>
                        <div class="icon">
                            <i class="${data.icon}"></i>
                        </div>
                
                        <div class="header">
                            ${data.title}
                            <svg width="11" height="11" viewBox="0 0 11 11" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M10.5727 5.14688C10.5727 7.90444 8.39148 10.1399 5.70087 10.1399C3.01025 10.1399 0.829071 7.90444 0.829071 5.14688C0.829071 2.38932 3.01025 0.15387 5.70087 0.15387C8.39148 0.15387 10.5727 2.38932 10.5727 5.14688ZM1.65479 5.14688C1.65479 7.43706 3.46628 9.29362 5.70087 9.29362C7.93545 9.29362 9.74694 7.43706 9.74694 5.14688C9.74694 2.8567 7.93545 1.00014 5.70087 1.00014C3.46628 1.00014 1.65479 2.8567 1.65479 5.14688Z" fill="white" fill-opacity="0.1"/>
                                <mask id="path-2-inside-1_79_62" fill="white">
                                    <path d="M10.5727 5.14688C10.5727 6.1344 10.2869 7.09975 9.75161 7.92084C9.2163 8.74194 8.45542 9.3819 7.56522 9.75981C6.67502 10.1377 5.69546 10.2366 4.75043 10.0439C3.80539 9.85129 2.93732 9.37575 2.25599 8.67747L2.83986 8.07906C3.40571 8.659 4.12666 9.05394 4.91152 9.21394C5.69638 9.37394 6.50991 9.29182 7.24923 8.97796C7.98855 8.66411 8.62046 8.13261 9.06505 7.45068C9.50964 6.76875 9.74694 5.96702 9.74694 5.14688H10.5727Z"/>
                                </mask>
                                <path d="M10.5727 5.14688C10.5727 6.1344 10.2869 7.09975 9.75161 7.92084C9.2163 8.74194 8.45542 9.3819 7.56522 9.75981C6.67502 10.1377 5.69546 10.2366 4.75043 10.0439C3.80539 9.85129 2.93732 9.37575 2.25599 8.67747L2.83986 8.07906C3.40571 8.659 4.12666 9.05394 4.91152 9.21394C5.69638 9.37394 6.50991 9.29182 7.24923 8.97796C7.98855 8.66411 8.62046 8.13261 9.06505 7.45068C9.50964 6.76875 9.74694 5.96702 9.74694 5.14688H10.5727Z" stroke="white" stroke-width="2" mask="url(#path-2-inside-1_79_62)"/>
                            </svg>
                            
                        </div>
                
                        <span>${text}</span>
                    </div>
                `)

                let hint = $(`#hint${id}`)
                setTimeout(() => {
                    hint.fadeOut(1000, () => {
                        hint.remove();
                    })
                }, time);
            } else if (data.interface == "achievementNotify") {
                var _this = this;
                var sleep = (ms) => {
                    return new Promise(resolve => setTimeout(resolve, ms));
                }
                var achieve_notify_run = async () => {
                    if (this.achieve_notify) {
                        $(".hud-top-right-flex .achievement-info").animate({right: "-500px"}, {
                            duration: 500,
                            complete: function() {
                                $(this).fadeOut(100);
                            }
                        });
                        if (typeof(this.achieve_notify) != "boolean") {
                            clearTimeout(this.achieve_notify);
                        }
                        this.achieve_notify = false;
                        await sleep(1000);
                    }
    
                    _this.achieve_notify = true;
                    $(".hud-top-right-flex .achievement-info").fadeIn(50, function() {
                        $(this).animate({right: 0}, {
                            duration: 1000,
                            complete: function() {
                                _this.achieve_notify = setTimeout(() => {
                                    $(this).animate({right: "-500px"}, {
                                        duration: 1000,
                                        complete: function() {
                                            $(this).fadeOut(100);
                                            _this.achieve_notify = false;
                                        }
                                    });
                                }, 4000);
                            }
                        });
                    });
                    this.achieve_notify_title = data.title || "Realizare";
                    this.achieve_notify_text = data.text;
                    this.achieve_notify_complete = data.complete;
                    this.achieve_notify_progress = data.progress;
                    this.achieve_notify_task = data.task;
                }
                achieve_notify_run();
            }
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        sendError(error = "nu a fost definit un mesaj", time = 5000) {
 
            if (this.errortime) {
                clearTimeout(this.errortime);
                $(".api-fail-msg").hide();
            };

            $(".api-fail-msg").children("p").text(error);
            $(".api-fail-msg").show();
            
            this.errortime = setTimeout(() => {
                $(".api-fail-msg").fadeOut();
                this.errortime = false;
            }, time)
        },

        sendInfo(info = "nu a fost definit un mesaj", time = 5000) {
 
            if (this.infotime) {
                clearTimeout(this.infotime);
                $(".api-info-msg").hide();
            };

            $(".api-info-msg").children("p").text(info);
            $(".api-info-msg").show();
            
            this.infotime = setTimeout(() => {
                $(".api-info-msg").fadeOut();
                this.infotime = false;
            }, time)
        },

        truncateText(text, max) {
            return text.substr(0,max-1)+(text.length>max?'...':''); 
        },

    }
})

const hudNotifications = new Vue({
    el: ".hud-notifications",
    data: {
        zoom: 0,
    },
    mounted() {
        window.addEventListener("resize", this.handleResize)
    },
    methods: {
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
    }
})

const hudDialog = new Vue({
    el: ".hud-dialog",
    data: {
        active: false,
        zoom: 0,
        id: 0,
        title: "",
        description: "",
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.onResize)
    },
    methods: {

		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy(false);
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "dialog")
                this.build(data.id, data.title, data.description);
        },

        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        build(id = 0, title = "Confirmare", description = "Nu a fost setata o descriere.") {

            if (!id) id = 0;
            if (!title) title = "Confirmare";
            if (!description) description = "Nu a fost setata o descriere.";

            var audio = new Audio("../public/sounds/request.mp3")
            audio.volume = 0.5;
            audio.play();

            this.active = true;
            this.id = id;
            this.title = title.toLowerCase();
            this.description = description;
        },
        
        destroy(ok) {
            if (!this.active) return;
            
            this.active = false;
            this.post("result:request", [this.id, ok]);
        },
    }
})


const hudPrompt = new Vue({
    el: ".hud-prompt",
    data: {
        active: false,
        zoom: 0,
        title: "",
        description: "",
        text: "",
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.onResize)
    },
    methods: {

        onMessage() {
            const data = event.data;

            if (data.interface == "prompt")
                this.build(data.title, data.description, data.text);
        },

        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },


        build(title = "Raspuns", description = "Introdu raspunsul tau in caseta disponibila mai jos.", text) {

            var audio = new Audio("../public/sounds/prompt.mp3")
            audio.volume = 0.5;
            audio.play();

            if (!title) title = "Raspuns";
            if (!description) description = "Introdu raspunsul tau in caseta disponibila mai jos.";

            this.text = "";
            this.active = true;
            this.title = title.toLowerCase();
            this.description = description;
            if (text) {
                this.text = text;
            }

            setTimeout(() => {
                $("#prompt-input").focus();
            }, 200);
        },
        
        destroy(ok) {
            if (!this.active) return;
            var response = String(this.text);

            if (!ok) {
                response = false;
            }

            if (!response || response.trim().length === 0) {
                response = false;
            }

            this.active = false;
            this.post("result:prompt", [response]);
        },

    }
})


const hudSelector = new Vue({
    el: ".hud-selector",
    data: {
        active: false,
        selected: false,
        zoom: 0,
        title: "",
        items: [],
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("resize", this.onResize)
    },
    methods: {

		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy(false);
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "selector")
                this.build(data.title, data.items);
        },

        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },


        build(title = "Raspuns", items) {

            var audio = new Audio("../public/sounds/prompt.mp3")
            audio.volume = 0.5;
            audio.play();

            if (!title) title = "Raspuns";

            this.items = items;
            this.title = title;
            this.active = true;
        },

        select(index) {
            this.selected = index;
        },
        
        destroy(ok) {
            if (!this.active) return;

            if (ok && !this.selected) return;

            this.active = false;
            this.post("result:selector", [ok ? this.selected : ok]);
        
            this.selected = false;
        },

    }
})

const bottomRightHud = new Vue({
    el: ".hud-bottom-right",
    data: {
        zoom: 0,
        show: true,
        
        binds: [],

        speedo: {
            show: false,
            electric: false,
            speed: 0,
            fuel: 0,
            seatbelt: false,
            odometer: "0.00",
            class: 0,
        },

        radar: {
            show: false,
            front: "Fara date",
            back: "Fara date",
            stop: false,
        },

        cardsFlip: false,
    },
    mounted() {
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("message", this.onMessage)

        const excludeClass = {
            8: true,
            21: true,
        }
    
        setInterval(() => {
            if (!this.speedo.seatbelt && this.speedo.show && !excludeClass[this.speedo.class]) {
                if (this.speedo && this.speedo.speed < 20) return;
                
                var audio = new Audio("../public/sounds/seatbelt.mp3")
                audio.volume = 0.15;
                audio.play();
            }
        }, 4000);
    },
    methods: {
        
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "bindsList") {
                if (data.event == "add") {
                    this.binds.push({key: data.key, text: data.text});
                } else if (data.event == "hide") {
                    this.binds = [];
                }
            } else if (data.interface == "setSpeedoValue") {
                if (data.show) {
                    this.speedo.show = true;
                    this.speedo.electric = data.electric;
                    this.speedo.speed = data.speed;
                    this.speedo.fuel = data.tank;
                    this.speedo.seatbelt = data.seatbelt;
                    this.speedo.odometer = data.odometer;
                    this.speedo.class = data.class;
                    this.updateRPM((data.rpm * 100) / 10);
                    $('.speed-limit').fadeIn();
                } else {
                    this.speedo.show = false;
                    $('.speed-limit').fadeOut();
                }            
            } else if (data.interface == "pdradar") {
                if (data.show != undefined) {
                    this.radar.show = data.show;
                }

                if (data.front != undefined && data.back != undefined) {
                    this.radar.front = data.front;
                    this.radar.back = data.back;
                }

                if (data.stop != undefined) {
                    this.radar.stop = data.stop;
                }
            } else if (data.interface == 'speedLimit') {
                $('.speed-limit').text(data.limit)
            }
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        updateRPM(rpm) {
            for (const index in rpmLineElements) {
                let element = rpmLineElements[index]
        
                if (index <= rpm) {
                    $('#'+element).attr('fill', '#7696c2').attr('fill-opacity', '0.9')
                } else {
                    $('#'+element).attr('fill', '#C4C4C4').attr('fill-opacity', '0.3')
                }
            }
        
            for (const index in rpmElements) {
                let element = rpmElements[index]
        
                if (index <= rpm) {
                    $('#'+element).attr('fill', '#a1c9ff').attr('fill-opacity', '0.1')
                } else {
                    $('#'+element).attr('fill', '#FBFBFB').attr('fill-opacity', '0.05')
                }
            }
        
            for (const index in rpmNumberElements) {
                let element = rpmNumberElements[index]
        
                if (index <= rpm) {
                    $('#'+element).attr('fill', '#a1c9ff').attr('fill-opacity', '1.0')
                } else {
                    $('#'+element).attr('fill', 'white').attr('fill-opacity', '0.5')
                }
            }
        }
    }
})


const bottomCenterHud = new Vue({
    el: ".hud-bottom-center",
    data: {
        zoom: 0,
        show: true,

        survival: {
            show: false,
            hunger: 0,
            thirst: 0,
        },
    },
    mounted() {
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("message", this.onMessage)
    },
    methods: {
        
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "survival") {
                if (!this.survival.show) {
                    this.survival.show = true;
                    
                    $(".hud-bottom-center .survival .bar").css("width", "50px");
                    setTimeout(() => {
                        $(".hud-bottom-center .survival .bar").css("width", "150px");
                    }, 500);

                    $(".hud-bottom-center .survival").fadeIn(1000, () => {
                        $(".hud-bottom-center .survival .food-bar .bar .fill").css("width", data.hunger + "%");
                        $(".hud-bottom-center .survival .water-bar .bar .fill").css("width", data.thirst + "%");
                    })
                } else {
                    $(".hud-bottom-center .survival .bar").css("width", "50px");
                    
                    $(".hud-bottom-center .survival").fadeOut(4000, () => {
                        $(".hud-bottom-center .survival .bar").css("width", "150px");
                        this.survival.show = false;
                    });
                }
            } else if (data.interface == 'updateSurvival') {
                $(".hud-bottom-center .survival .food-bar .bar .fill").css("width", data.hunger + "%");
                $(".hud-bottom-center .survival .water-bar .bar .fill").css("width", data.thirst + "%");
            }
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
    }
})

const minimapHud = new Vue({
    el: ".hud-minimap",
    data: {
        zoom: 0,
        show: true,
        
        district: "",
        street: "",
        direction: "",
        
        minimapPosX: 0,
        hour: "",
        date: "",

        money: 0,
        flow: false,
        flowtype: "+",
        flowtime: false,
        flowaudio: false,

        talking: false,
        talkDst: 1,
    },
    mounted() {
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("message", this.onMessage)
    
        var updateHour = () => {
            var date = new Date();
            var minutes = String(date.getMinutes()).padStart(2, '0');
            var hour = String(date.getHours()).padStart(2, '0');
        
            var dayOfMonth = String(date.getDate()).padStart(2, '0');
            var monthOfYear = String(date.getMonth() + 1).padStart(2, '0');
            var year = date.getFullYear();
        
            this.hour = `${hour}:${minutes}`;
            this.date = `${dayOfMonth}.${monthOfYear}.${year}`;
        }
        setInterval(updateHour, 1000);


    },
    methods: {
        
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "locationDisplay") {
                this.district = data.data.district;
                this.street = data.data.street;
            } else if (data.interface == "setHudMoney") {
                this.money = parseInt(data.cash);
            } else if (data.interface == "moneyFlow") {
                if (this.flowtime) {
                    this.flowaudio.pause();
                    this.flow = false;
                    clearInterval(this.flowtime);
                };
                
                setTimeout(() => {
                    this.flowaudio = new Audio("../public/sounds/cash-pay.mp3")
                    this.flowaudio.volume = 0.15;
                    this.flowaudio.play();
                    
                    this.flowtype = data.type;
                    this.flow = data.amount;
                    this.flowtime = setInterval(() => {
                        this.flow = false;
                    }, 3000);
                }, 50);
            } else if (data.interface == "setHudId") {
                this.id = data.id;
            } else if (data.interface == "setHudPlayers") {
                this.online = data.players;
            } else if (data.interface == "setVoiceLevel") {
                this.talkDst = parseInt(data.lvl);
            } else if (data.interface == "setVoiceState") {
                this.talking = data.tog;
            } else if (data.interface == "addNotify") {
                addNotify(data.type, data.time, data.title, data.text);
            }
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },


        getCardinalPoint(heading) {
            const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
            return points[Math.round(((heading % 360) / 45)) % 8];
        },

    }
})





// define as globals
globalThis.uiComponents = {};

globalThis.uiComponents.serverHud = serverHud;
globalThis.uiComponents.minimapHud = minimapHud;
globalThis.uiComponents.bottomRightHud = bottomRightHud;
globalThis.uiComponents.bottomCenterHud = bottomCenterHud;