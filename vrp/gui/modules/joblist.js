const jobList = new Vue({
    el: ".main-joblist",
    data: {
        active: false,
        zoom: 0,
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

            if (data.interface == "jobList")
                this.build();
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

        
        build() {
            this.active = true;
            $(".main-joblist").fadeIn(1000);
            this.post("setFocus", [true]);
        },
        
        setWaypoint(job) {
            const jobList = {

                "Taietor de iarba": [-1050.9725341797,6.0058469772339],
                "Constructor": [-848.66363525391,-799.65399169922],
                "Pilot Los Santos": [-1185.2652587891,-2674.0170898438],
                "Pilot Cayo Perico": [4427.7822265625,-4451.53125],
                "Pilot Grapeseed": [2139.9816894531,4788.71484375],
                "Culegator de portocale": [2031.8020019531,4733.4189453125],
                "Sofer de autobuz": [454.33969116211,-600.66009521484],
                "Pescar": [-1514.3322753906, 1512.4349365234, 115.28856658936],
                "Curatator de strazi": [1070.5645751953,-780.34704589844],
                "Mecanic": [-1601.3695068359,-832.49853515625],
                "Taxi": [895.46307373047,-179.29476928711],
                "Vanator": [-677.31420898438,5825.65625],
                "Furnizor de stocuri": [846.9814453125,-902.86309814453],
    
            }

            this.post("setMapPosition", [jobList[job][0], jobList[job][1], true]);
            this.destroy();
        },
        
        destroy() {
            this.active = false;
            $(".main-joblist").fadeOut(1000);
            this.post("setFocus", [false]);
            
            var tog = true;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        }
    }
})