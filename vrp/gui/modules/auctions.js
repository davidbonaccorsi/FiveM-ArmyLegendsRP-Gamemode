const auctions = new Vue({
    el: ".main-auctions",
    data: {
        active: false,
        zoom: 0,
        auctionData: [],
        auctionInterval: false,
        timeLeft: '00:00',
        timePassed: {
            minutes: 0,
            seconds: 0
        },
        auctionTop: [],
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("keydown", this.onKey)
    },
    methods: {
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

		onMessage() {
			const data = event.data;
		
			if (data.interface == "auctions") {
                if (data.action == "open") {
                    this.build(data.data);
                } else if (data.action == 'update') {
                    this.update(data.data);
                } else if (data.action == 'update-players') {
                    if (this.auctionData) {
                        this.auctionData.activePlayers = data.players;
                    }
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

		        
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        updateTop() {
            if (this.auctionData && this.auctionData.bids) {
                this.auctionTop = this.auctionData.bids.sort((a, b) => b.bid - a.bid).slice(0, 5);
            }
        },

        build(data) {
            this.active = true;
            this.post("setFocus", [true]);
            this.auctionData = data;

            if (this.auctionData) {
                this.updateTop();
                $(".main-auctions .auctions-flex .bid-image").css("--url", `url(${this.auctionData.img})`);     
                const updateTimePassed = async () => {
                    if (this.auctionData && this.auctionData.lastBidder && this.auctionData.lastBidder.time) {
                        let currentTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
                        let auctionTime = this.auctionData.lastBidder.time * 1000;
                        let diffInMilliseconds = currentTime - auctionTime;
                        let minutes = Math.floor(diffInMilliseconds / (1000 * 60)).toString().padStart(2, '0');
                        let seconds = Math.floor((diffInMilliseconds / 1000) % 60).toString().padStart(2, '0');

                        this.timePassed = {
                            minutes: minutes,
                            seconds: seconds
                        }
                    }
                }

                const updateCountdown = async () => {
                    if (!this.active) {
                        clearInterval(this.auctionInterval);
                        return;
                    }

                    updateTimePassed();
                    let currentTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
                    let auctionTime = this.auctionData.time * 1000;
                    let diffInMilliseconds = auctionTime - currentTime;
                    let minutes = Math.floor(diffInMilliseconds / (1000 * 60)).toString().padStart(2, '0');
                    let seconds = Math.floor((diffInMilliseconds / 1000) % 60).toString().padStart(2, '0');

                    if (minutes <= 15) {
                        $(".main-auctions .auctions-flex .bid .time-remaining").css('color', '#ebce69')
                    } else if (minutes <= 5) {
                        $(".main-auctions .auctions-flex .bid .time-remaining").css('color', '#e35555')
                    } else {
                        $(".main-auctions .auctions-flex .bid .time-remaining").css('color', '#fff')
                    }

                    this.timeLeft = parseInt(minutes) > 0 ? minutes + ":" + seconds : "00:00";
                }
                this.auctionInterval = setInterval(updateCountdown, 1000);
            }
        },

        update(data) {
            this.auctionData = data;
            this.updateTop();
        },

        bid() {
            this.post('bid')
        },

        getAuctionBid() {
            if (this.auctionData && this.auctionData.lastBidder && this.auctionData.lastBidder.bid) {
                return Math.floor(parseInt(this.auctionData.lastBidder.bid) + (Math.floor(parseInt(this.auctionData.lastBidder.bid) * 50) / 100));
            }

            return this.auctionData.startPrice || '0';
        },

        destroy() {
            this.active = false;
            clearInterval(this.auctionInterval);
            this.post("setFocus", [false]);
        }
    }
})