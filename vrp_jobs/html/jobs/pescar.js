
const fisherJob = new Vue({
    el: ".main-fisher",
    data: {
        active: false,
        zoom: 0,
        job: "",
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
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.job == "fisher")
                this.build(data);
        },

		async post(url, data = {}, res = GetParentResourceName()) {
			const response = await fetch(`https://${res}/${url}`, {
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
            this.job = data.group;

            var tog = false;

            this.post("setFocus", [true]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");

        },

        destroy() {
            this.active = false;
            var tog = true;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");
            this.post("setFocus", [false]);
        },
    }
})


// game

const fishGame = {
    progressEm: $(".fishergame-flex .line > div"),
    keyEm: $(".fishergame-flex .key"),
    progress: 0,
    minp: 0,
    maxp: 100,

    itime: 100, // ms
    valperi: -0.5,
    disabled: true,

    fishtime: false,

	async post(url, data = {}, res = GetParentResourceName()) {
		const response = await fetch(`https://${res}/${url}`, {
		    method: 'POST',
		    headers: { 'Content-Type': 'application/json' },
		    body: JSON.stringify(data)
		});
		
		return await response.json();
	},

    endGame(ok) {
        this.setFishGameState(true);
        this.post("fisher:gameDone", [ok]);
        this.dropToMin(1);
    },

    addToProgress(value, duration) {
        if (this.disabled) return;
        this.progress += value;
        if (this.progress < this.minp) {
            this.progress = this.minp;
        }
        if (this.progress >= this.maxp) {
            this.progress = this.maxp;
            
            // end game
            this.endGame(true);

            return;
        }
        this.drawCurrentProgress(this.progress, duration);
    },
    
    dropToMin(duration) {
        this.progress = this.minp;
        this.drawCurrentProgress(this.progress, duration);
    },

    drawCurrentProgress(value, duration) {
        this.progressEm.css('width', value + "%");
        this.progressEm.css('transitionDuration', duration + 'ms');
    },

    pressButton(pressed) {
        this.keyEm[pressed ? "addClass" : "removeClass"]("pressed");
    },

    setFishGameState(tog) {
        this.disabled = tog;

        if (this.fishtime) clearTimeout(this.fishtime);
        if (!tog) {
            this.fishtime = setTimeout(() => {
                if (!this.disabled) {
                    this.endGame(false);
                }
                this.fishtime = false;
            }, 10000)
        }

        $(".fisher-minigame")[!tog ? "fadeIn" : "fadeOut"](1000);
        fisherJob.post("setFocus", [!tog]);
    },


    ready() {
        setInterval(() => {
            this.addToProgress(this.valperi, this.itime);
        }, this.itime);
    }
}
fishGame.ready();

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.job == "fishgame")
        fishGame.setFishGameState(false);
});

window.addEventListener("keydown", (event) => {
    if (fishGame.disabled) return;
    
    if (event.code === "Space") {
        fishGame.pressButton(true);
    }
})

window.addEventListener('keyup', function(event) {
    if (event.code === "Space") {
        fishGame.pressButton(false);
        fishGame.addToProgress(5, fishGame.itime);
    }
});