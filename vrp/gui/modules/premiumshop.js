const premiumShop = new Vue({
    el: ".premiumshop-layout",
    data: {
        active: false,
        page: "popular",
        cars: {
            "akumac": 15,
            "asteropers": 25,
            "auroras": 25,
            "buffalo4h": 15,
            "callista": 30,
            "cheetahfel": 30,
            "clique2": 30,
            "coquette4c": 15,
            "elegyrace": 40,
            "f620d": 15, 
            "feltzer9": 20,
            "gauntletc": 20,
            "gauntletstx": 20,
            "hachura": 15,
            "hotringfr": 15,
            "kriegerc": 30,
            "kampfer": 15,
            "m420": 10,
            "meteor": 15,
            "missile": 15,
            "nerops": 30,
            "paragonxr": 30,
            "picadorexr": 30,
            "playboy": 30,
            "raidenz": 30,
            "rh4": 30,
            "roxanne": 30,
            "sheavas": 30,
            "spzr250": 30,
            "stardust": 30,
            "stingersc": 30,
            "sunrise1": 30,
            "toreador2": 30,
            "turismo2lm": 30,
            "zr380s": 30
        },
        coins: 0,
        lastPage: false,
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
    },
    methods: {
        
        onKey() {
            var theKey = event.code;

            if (theKey == "Escape" && this.active){
                if (this.page == "prime") {
                    this.page = this.lastPage || "popular";
                    return false;
                }

                this.destroy();
            }
        },

        onMessage() {
            const data = event.data;

            if (data.interface == "premiumShop") {
                if (data.act == "build") {
                    this.build();
                } else if (data.act == "update") {
                    this.coins = data.coins;
                }
            }
        },

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        async build() { 
            this.active = true;
            this.page = "popular";
            this.post("setFocus", [true]);

            let coins = await this.post("shop:getCoins");
            this.coins = coins;

            $(".premiumshop-layout").fadeIn(1000);
        },

        goBack() {
            if (this.page == "prime") {
                this.page = this.lastPage || "popular";
                return false;
            }

            this.destroy();
        },

        addFunds() {
            window.invokeNative('openUrl', 'https://shop.armylegends.ro');
        },

        setPage(page) {
            if (page == 'prime') {
                this.lastPage = this.page;
            }

            this.page = page;
        },

        async buy(choice, close) {
            this.post("shop:buyProduct", [choice]);

            if (close) {
                this.destroy()
            } else {
                let coins = await this.post("shop:getCoins");
                this.coins = coins;
            }
        },

        destroy() {
            this.active = false;
            this.post('setBlur', [false]);
            this.post('setFocus', [false]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
            
            $(".premiumshop-layout").fadeOut(1000);
        },
    }
})