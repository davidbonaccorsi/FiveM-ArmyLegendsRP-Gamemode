
const bunker = new Vue({
    el: ".main-bunker",
    data: {
        active: false,
        zoom: 0,
        owner: false,
        player: 0,
        bunkers: [],
        ownedBunker: [],
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
		
			if (data.interface == "bunker")
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
            this.bunkers = data.bunkerData;
            this.owner = data.owned;
            this.player = data.id;
            this.ownedBunker = data.ownedBunker;
            this.post("setFocus", [true]);

            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
        },

        enterBunker(bunker) {
            this.post('bunker:enter', [bunker])
            this.destroy();
        },

        sellBunker(bunker) {
            this.post('bunker:sell', [bunker])
            this.destroy()
        },

        lockBunker(bunker) {
            this.post('bunker:lock', [bunker])
            this.destroy()
        },

        buyBunker() {
            this.destroy()
            this.post('bunker:buy')
        },
        
        destroy() {
            this.active = false;            
            this.post("setFocus", [false]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        }
    }
})


const bunkerInfo = new Vue({
	el: ".main-bunkerinfo",
	data: {
        active: false,
        zoom: 0,
        craftings: [],
        ownedCraftings: [],
        bunkerMissions: [],
        bunkerDays: 0,
    },
    mounted() {
		window.addEventListener("keydown", this.onKey)
		window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
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

            if (data.interface == "bunkerInfo")
                this.build(data.data);
        },
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
        onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},
        build(data) {
            this.active = true;
            this.craftings = data.craftings;
            this.ownedCraftings = data.ownedCraftings;
            this.bunkerMissions = data.bunkerMissions;

            this.bunkerDays = this.getExpireDate(data.bunkerExpire);

            $(".main-bunkerinfo").fadeIn(1000);
            this.post("setFocus", [true]);
        },
        buyCrafting(crafting) {
            this.destroy()
            this.post('bunker:buyCrafting', [crafting])
        },
        destroy() {
            this.active = false;
            this.post("setFocus", [false]);
            this.post('bunker:close');
            $(".main-bunkerinfo").fadeOut(1000);
        },
        startMission: function(mission) {
            this.post('bunker:startMission', [mission]);
            this.destroy();
        },
        payBunker: function() {
            this.destroy();
            this.post('bunker:buyDays');
        },
        getExpireDate: function(expireDate) {
            var startTimestamp = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
            var endTimestamp = (expireDate || 0) * 1000;
            var diffInMilliseconds = endTimestamp - startTimestamp;

            var days = Math.floor(diffInMilliseconds / (1000 * 60 * 60 * 24));
            if (days < 0) { days = 0;}

            return days;
        },
        getMissionCooldown: function(mission) {
            var endTimestamp = (this.bunkerMissions[mission] || 0) * 1000;
            
            var startTimestamp = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
            var diffInMilliseconds = endTimestamp - startTimestamp;
            var hours = Math.floor(diffInMilliseconds / (1000 * 60 * 60)).toString().padStart(2, '0');
            var minutes = Math.floor((diffInMilliseconds % (1000 * 60 * 60)) / (1000 * 60)).toString().padStart(2, '0');

            if (minutes < 0) {
                minutes = '00';
            }

            if (hours < 0) {
                hours = '00';
            }

            const time = hours + ':' + minutes;
            return time
        },
    }
});


const bunkerCraft = new Vue({
    el: ".main-bunkercraft",
    data: {
        active: false,
        zoom: 0,
        bunkerData: [],
        time: '00:00',
        percentage: 0,
        bunkerInterval: null,
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
        window.addEventListener("keydown", this.onKey)
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

            if (data.interface == "bunkerCraft")
                this.build(data.data);
        },
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
        onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},
        
        
        reverseObject(obj) {
            const newObject = {};
            const keys = Object.keys(obj).reverse();
            keys.forEach(key => {
                newObject[key] = obj[key];
            });
            return newObject;
        },

        calculatePercentage(startTimestamp, endTimestamp, minutes) {
            const millisecondsPerMinute = 60 * 1000;
            const millisecondsPerSecond = 1000;
          
            // Calculate the time difference in milliseconds
            const timeDifference = endTimestamp - startTimestamp;

            // Convert milliseconds to minutes and seconds
            const minutesLeft = Math.floor(timeDifference / millisecondsPerMinute);
            const secondsLeft = Math.floor((timeDifference % millisecondsPerMinute) / millisecondsPerSecond);
          
            // Calculate the total number of seconds
            const totalSeconds = minutesLeft * 60 + secondsLeft;
          
            // Calculate the percentage
            const percentage = (totalSeconds / (minutes * 60)) * 100; // Assuming the total time is 1 hour (60 minutes)
            const asendetingPercentage = 100 - percentage
            const clampedAscendingPercentage = Math.max(0, Math.min(100, asendetingPercentage));

            return clampedAscendingPercentage;
        },    

        updateCooldowns(endTimestamp, min) {
            const startTimestamp = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
            const diffInMilliseconds = endTimestamp - startTimestamp;
            const minutes = Math.floor(diffInMilliseconds / (1000 * 60)).toString().padStart(2, '0');
            const seconds = Math.floor((diffInMilliseconds / 1000) % 60).toString().padStart(2, '0');
          
            const percentage = this.calculatePercentage(startTimestamp, endTimestamp, min)
            if (isNaN(percentage)) {
                this.percentage = 0;
            } else {
                this.percentage = percentage.toFixed(1);
            }
            
            if (isNaN(minutes) || isNaN(seconds)) {
                this.time = 0;
            } else {
                this.time = minutes < 0 && seconds < 0 && '00:00' || minutes + ":" + seconds;
            }
        },

        craftItem() {
            if (this.percentage == 0) {
                this.post('bunker:craftItem', [this.bunkerData && this.bunkerData.location]).then((data) => {
                    this.updateCooldowns(data.bunkerInfo.finishTime * 1000, data.minutes)
                })
            } else if (this.percentage == 100) {
                this.destroy();
                this.post('bunker:collectCrafting', [this.bunkerData && this.bunkerData.location])
            }
 
        },

        build(data) {
            if (this.active) return;

            this.bunkerData = data;
            this.active = true;
            this.post('setFocus', [true])
            
            if (data && data.bunkerInfo) {
                if (data.bought) {
                    this.bunkerInterval = setInterval(() => {
                        if (!this.active) {
                            clearInterval(this.bunkerInterval);
                        }
                        this.updateCooldowns(data.bunkerInfo.finishTime * 1000, data.minutes)
                    })
                } else {
                    this.time = '00:00';
                    this.percentage = 0;
                }
            }
        },
        
        destroy() {
            this.active = false;
            this.post('setFocus', [false])
        }
    }
})
