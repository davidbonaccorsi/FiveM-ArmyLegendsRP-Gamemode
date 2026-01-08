new Vue({
	el: ".bank-robbery",
	data: {
        actions: {},
        time: "00:00",
        active: false,
	},
    
	mounted() {
        window.addEventListener("message", this.onMessage)
	},

	methods: {
        onMessage(event) {
            const data = event.data;
            
            switch(data.action) {
                case "updateTime":
                    this.time = data.time;
                break

                case "showActions":
                    if (!this.active) {
                        this.active = true
                    }
                break

                case "updateActions":
                    this.actions = data.robberyData;
                break

                case "closeActions":
                    this.active = false;
                break

                case 'robberyAlert':
                    $('.robbery-alert').show();
                    $('.alert-text').text(data.text);

                    setTimeout(function(){
                        $('.robbery-alert').fadeOut();
                    }, 9000);
                break
            }
        },
	},
})