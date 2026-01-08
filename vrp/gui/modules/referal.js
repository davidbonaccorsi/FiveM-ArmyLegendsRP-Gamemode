var refferalMenu = new Vue({
    el: '.referal-wrapper',
    data: {
        active: false,
        userinvites: 0,
        refferalData: [],
        refferalCode: '',
        lastHours: 0,
        progress: 0,
        giftProgress: false,
    },
    mounted() {
		window.addEventListener("keydown", this.onKey)

        this.giftProgress = new ProgressBar.Path('#refferal-line', {
            easing: 'easeInOut',
            duration: 0
        });
        this.giftProgress.animate(0.0)
        
    },
    methods: {
        onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
        build: function(data) {
            this.active = true
            this.refferalData = data.invitesData
            this.userinvites = data.referalInvites
            this.refferalCode = data.refferalCode
            this.lastHours = data.lastHours

            this.progress = Math.min((data.lastHours / 80 ) * 100, 100);
            this.giftProgress.animate(this.progress / 100)
            
            $('#referal-code').val(data.refferalCode)
            $('.referal-wrapper').fadeIn(1000)
        },

        copyRefferal: function() {
            var textarea = document.createElement('textarea');
            textarea.value = this.refferalCode;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
        },

        destroy: function() {
            this.active = false
            $('.referal-wrapper').fadeOut(500)
            this.post('setFocus', [false])
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        },
    },
});