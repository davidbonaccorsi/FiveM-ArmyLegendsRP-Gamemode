const barbut = new Vue({
    el: ".main-barbut",
    data: {
        active: false,
        zoom: 0,
        bet: 0,
        role: "creator",
        feedback: false,
        results: false,

        rolling: false,
        dcs: [1, 2, 3, 4],
        lastRoll: 0,

        name: "...",
        enemy: "...",

    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("message", this.onMessage)

        
        this.dcsObj = [
            $("#barbut-dice-0"),
            $("#barbut-dice-1"),
            $("#barbut-dice-3"),
            $("#barbut-dice-2"),
        ];

    },
    methods: {

        onMessage() {
            const data = event.data;

            if (data.interface == "barbut")
                this.build(data);
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


        build(data) {
            this.active = true;
            this.bet = data.bet;
            this.role = data.role;
            this.feedback = false;
            this.results = false;
            this.name = data.playerTags[0];
            this.enemy = data.playerTags[1];
            this.rolling = false;

            for (let i = 0; i < this.dcs.length; i++) {
                this.dcsObj[i].css("background-image", `url(../../public/dices/1.png)`);
            }

            $(".main-barbut").fadeIn(1000);
            $(".main-barbut").hide();
            $(".main-barbut").fadeIn(1000);

            this.post("setFocus", [true]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
        },

        destroy() {
            this.active = false;
            $(".main-barbut").fadeOut(1000);

            this.post("setFocus", [false]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        },

        abortGame() {
            this.post("barbut:abortGame");
            this.destroy();
        },

        changeBet() {
            this.rolling = true;
            this.post("vrp:triggerServerEvent", ["vrp-barbut:changeBet"]);
        },

        startRoll() {
            this.rolling = true;
            this.roll();
            this.post("barbut:startRoll");
            setTimeout(() => {
                this.rolling = false;
                this.post("vrp:triggerServerEvent", ["vrp-barbut:doneRolls"]);
                this.post("barbut:getResults");
            }, 4000)
        },

        roll() {
            if (!this.rolling) return;

            const time = Date.now();
            if (time - this.lastRoll > 100) {
                for (let i = 0; i < this.dcs.length; i++) {
                    this.dcs[i] = Math.floor(Math.random() * 6) + 1;
                    this.dcsObj[i].css("background-image", `url(../../public/dices/${this.dcs[i]}.png)`);
                }
                
                this.lastRoll = time;
            }

            requestAnimationFrame(this.roll);
        }
    }
})
