
const turfs = new Vue({
    el: "#wars",
    data: {
        zoom: 0,
        uName: "",
        uScore: 0,
        tName: "",
        tScore: 0,

        min: 20,
        sec: 0,
        active: false,
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
    },
    methods: {

        onMessage() {
            const data = event.data;

            if (data.type == "kill") {
                this.addKill(data);
            } else if (data.type == "timer") {
                if (data.hide) {
                    this.active = false;
                } else {
                    if (!this.active) {
                        $(".main-killfeed").find("div").remove();
                    }
                    this.active = true;
                    this.min = data.m;
                    this.sec = data.s;

                    if (this.min == 0 && this.sec == 0) {
                        this.active = false;
                    }
                }
            } else if (data.type == "setScore") {
                this.uName = data.uName;
                this.uScore = data.uScore;
                this.tName = data.tName;
                this.tScore = data.tScore;
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

        addKill(data) {
            var [killer, victim, logType, headShot] = [data.killer, data.victim, data.logType, data.headShot];
            
            if(logType == 0)
                logType = "log-2";
            else
                logType = "log-1";

            var kill = $(`
                <div class="log ${logType}${headShot ? ' headshot' : ''}" style="display: none";>
                    ${killer}
                    <div>
                        <img src="https://cdn.discordapp.com/attachments/872567779419635725/1119997909136588921/kill.png">
                    </div>
                    ${victim}
                </div> 
            `)

            $(".main-killfeed").append(kill);
            kill.fadeIn(1000);
            setTimeout(() => {
                kill.fadeOut(1000, () => {
                    kill.remove();
                });
            }, 5000)
        }
    }
})

