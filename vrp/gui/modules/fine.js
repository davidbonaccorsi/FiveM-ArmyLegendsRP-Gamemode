const fine = new Vue({
    el: ".fine",
    data: {
        active: false,
        fineData : [],
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
    },
    methods: {
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == 'fine') {
                this.build(data.data);
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

        getDateFromTimestamp(timestamp) {
            const date = new Date(timestamp * 1000);
            const day = date.getDate();
            const month = date.getMonth() + 1;
            const year = date.getFullYear();
            
            return `${day}/${month}/${year}`;
        },

        build(data) {
            this.active = true
            this.fineData = data
            $('.fine').fadeIn(150, () => {
                setTimeout(() => {
                    $('.fine').fadeOut()
                    this.active = false
                }, 10000)
            })
        }
    }
});