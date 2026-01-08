const markets = new Vue({
    el: ".main-markets",
    data: {
        active: false,
        zoom: 0,
        search: "",
        gtype: "",
        name: "",
        balance: 0,
        filtered: [],
        products: [],
        categories: [],
        id: false,
        bizPos: false,
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
				this.destroy(false);
		},

        onMessage() {
            const data = event.data;

            switch (data.interface) {
                case "market":
                    this.build(data.data);
                break;
                
                case "updateMarketData":
                    this.products[data.item].stock = data.stock;
                    // this.balance = data.balance;
                break;
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
        
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        refreshSearch(){
			this.filtered = Object.fromEntries((Object.entries(this.products)).filter(([key, item]) => {
				return item.label.toLowerCase().includes(this.search.toLowerCase()) && item.category.toLowerCase() == this.active.toLowerCase();
			}));
		},

        build(data) {
            this.gtype = data.gtype;
            this.name = data.name;
            this.balance = data.money;
            this.products = data.items;

            if (data.stock)
                Object.keys(this.products).forEach(key => this.products[key].stock = data.stock[key]);

            this.filtered = this.products;
            this.categories = data.categories;
            this.id = data.id;
            this.bizPos = data.bizPos;

            this.active = data.categories[0];
            this.refreshSearch();
            $(".main-markets").fadeIn(1000);
        
            this.post("setFocus", [true]);
        },

        setCategory(category) {
            this.active = category;
            this.refreshSearch();
        },

        buy(item){
            this.post("vrp:triggerServerEvent", ["vrp-markets:buy", item, this.gtype, this.id]);
        },

        destroy() {
            this.active = false;
            $(".main-markets").fadeOut(1000);
            
            this.post("setFocus", [false]);

            if (this.gtype == "Pescarie") {
                this.post("vrp:triggerServerEvent", ["vrp_fisher:sellFish"]);
            }
        },
    }
})

const marketBiz = new Vue({
    el: ".main-market-biz",
    data: {
        active: false,
        zoom: 0,
        items: [],
        overlay: false,
        cost: 0,
        profit: 0,
        bizid: 0,
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
				this.destroy(false);
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "marketBiz")
                this.build(data.data);
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
            this.bizid = data.bizid;
            this.items = data.items;
            this.profit = data.profit;
            $(".main-market-biz").fadeIn(1000);
        
            this.post("setFocus", [true]);
        },

        setOverlay(tog, item, index) {
            if (!tog) {
                this.overlay = false;
                return
            }

            if (this.overlay) return;
            this.overlay = item;
            this.overlay.key = index;
            this.cost = this.overlay.biz_price;
            this.overlay.model = 1;

            $(".market-biz-flex .buy-overlay").fadeIn(1000, () => {
                $(".market-biz-flex .buy-overlay .to-show").fadeIn(1000);
            });
        },

        getCost() {
            if (!this.overlay) return false;

            this.cost = this.overlay.model * this.overlay.biz_price;
        },

        buy() {
            var item = this.overlay;

            this.setOverlay(false);
            this.post("vrp:triggerServerEvent", ["vrp-markets:orderStock", this.bizid, item.key, parseInt(item.model)]);
        },

        withdraw() {
            if (this.profit < 1) return serverHud.sendError("Nu ai un profit pe care il poti retrage.");

            this.post("vrp:triggerServerEvent", ["vrp-markets:withdrawProfit", this.bizid]);
            this.destroy();
        },

        sellMarket() {
            this.post("vrp:triggerServerEvent", ["vrp-markets:sellMarket", this.bizid]);
            this.destroy();
        },

        destroy() {
            this.active = false;
            this.overlay = false;
            $(".main-market-biz").fadeOut(1000);
            
            this.post("setFocus", [false]);
        },
    }
})
