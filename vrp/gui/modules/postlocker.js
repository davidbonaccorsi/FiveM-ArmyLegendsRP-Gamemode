const postLocker = new Vue({
    el: ".main-postlocker",
    data: {
        active: false,
        zoom: 0,
        packages: [],
        username: "",
        notifytime: false,
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("keydown", this.onKey)
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

            if (data.interface == "postLocker") {
                this.build(data);
            } else if (data.interface == "postNotify") {

                var _this = this;
                var sleep = (ms) => {
                    return new Promise(resolve => setTimeout(resolve, ms));
                }
                var post_notify_run = async () => {
                    if (this.notifytime) {
                        $(".post-notify-dist").fadeOut(500, () => {
                            $(".post-notify").animate({right: "-500px"}, {
                                duration: 500,
                                complete: function() {
                                    $(this).fadeOut(100);
                                }
                            });
                        });
                        if (this.notifytime) {
                            clearTimeout(this.notifytime);
                        }
                        this.notifytime = false;
                        await sleep(1000);
                    }
    
                    $(".post-notify").fadeIn(50, function() {
                        $(this).animate({right: '41px'}, {
                            duration: 1000,
                            complete: function() {
                                $(".post-notify-dist").text(`${data.distance}m distanta de locker`);
                                $(".post-notify-dist").fadeIn(1500);

                                _this.notifytime = setTimeout(() => {
                                    $(".post-notify-dist").fadeOut(1500, () => {
                                        $(this).animate({right: "-500px"}, {
                                            duration: 1000,
                                            complete: function() {
                                                $(this).fadeOut(100);
                                                _this.notifytime = false;
                                            }
                                        });
                                    });
                                }, 4000);
                            }
                        });
                    });
                }
                post_notify_run();
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

        build(data) {
            this.active = true;
            this.packages = data.packages;
            this.username = data.username;

            this.post("setFocus", [true]);

            var tog = false;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        },

        
        getShownItems() {
            return Object.keys(this.packages).length;
        },

        destroy() {
            this.active = false;
            this.post("setFocus", [false]);

            var tog = true;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        }
    }
})