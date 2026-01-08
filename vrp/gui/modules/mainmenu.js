const mainMenu = new Vue({
    el: '.main-player-menu',
    data: {
        active: false,
        zoom: 0,

        username: "",
        refferal: 'R-1',
        coins: 500,
        cash: '2 500',
        bank: '2 500',
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
    },
    methods: {
        
        onKey() {
            var theKey = event.code;

            if (theKey == "Escape" && this.active)
                this.destroy(true);
        },

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

            if (data.interface == "menu")
                this.build(data.data);
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },


        build(data) {
            this.active = true;

            this.cash = data.cash;
            this.bank = data.bank;
            this.username = data.username;
            this.coins = data.coins;
            this.refferal = data.refferal;

            this.post("setFocus", [true]);
            this.post("setGameBlur", [true]);
        },

        destroy(focus) {
            this.active = false;
            
            if (focus) {
                this.post("setFocus", [false]);
                this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
                this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
            }
            this.post("setGameBlur", [false]);
        },

        async open(interface) {
            if (interface == 'shop') {
                this.destroy(false);
                premiumShop.build();
            } else if (interface == 'jobs') {
                this.destroy(false);
                jobList.build();
            } else if (interface == 'investments') {
                this.destroy(false);
                this.post("vrp:triggerServerEvent", ["vrp-investments:openMenu"]);
            } else if (interface == 'character-stats') {
                this.destroy(false);
                this.post("vrp:triggerServerEvent", ["vrp-stats:openPlayer"]);
            } else if (interface == 'faction') {
                this.post('menu:factionData').then((data) => {
                    if (!data) {
                        return serverHud.sendError("Nu faci parte dintr-o factiune.");
                    }

                    if (data.dailyData && data.dailyData.collectedDays > 50) {
                        return serverHud.sendError("Ai colectat toate recompensele zilnice.");
                    }

                    this.destroy(false)
                    factionMenu.build(data)
                })
            } else if (interface == 'daily-reward') {
                this.destroy(false)
                this.post('menu:openDaily').then((data) => {
                    dailyReward.build(data);
                })
            } else if (interface == 'refferal') {
                this.destroy(false)
                this.post('menu:refferal').then((data) => {
                    refferalMenu.build(data);
                })
            } else if (interface == 'achivements') {
                this.destroy(false);
                this.post("vrp:triggerServerEvent", ["vrp-achievements:openMenu"]);
            } else if (interface == 'settings') {
                this.destroy(true)
                this.post('menu:settings')
            }
        },
    },
});