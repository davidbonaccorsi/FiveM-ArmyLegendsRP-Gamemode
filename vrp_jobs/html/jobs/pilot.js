
const pilotJob = new Vue({
    el: ".main-pilotamm",
    data: {
        active: false,
        zoom: 0,
        passengers: 0,
    },
    mounted() {
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
    },
    methods: {
        onMessage() {
            const data = event.data;

            if (data.job == "setPilotAmm") {
                this.passengers = data.amm;
            } else if (data.job == "setPilotShow") {
                this.active = data.tog;
            }
        },
        
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
    }
})
