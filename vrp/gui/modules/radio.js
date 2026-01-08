const radioSystem = new Vue({
    el: ".radio-layout",
    data: {
        active: false,
        settingPreset: false,
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
            var data = event.data;

            if (data.interface == "radio"){
                data.state ? this.build() : this.destroy(true);
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

        build() {
            this.active = true;
            $(".radio-layout").fadeIn(1000);
        },

        toggle(join) {
            var channel = $('#radio-channel').val();

            if (join && channel.length) {
                this.post('radio:join', [channel]);
            } else if (!join) {
                this.post('radio:leave');
            }
        },

        changeVolume(type) {
            this.post(`radio:volume_${type}`);
        },

        async presetChannel(preset) {
            if (this.settingPreset) {

                this.post('radio:preset_set', [preset]);
                this.settingPreset = false;

            } else {

                var frequency = await this.post("radio:preset_join", [preset]);

                if (frequency)
                    $('#radio-channel').val(frequency);
            }
        },

        setPreset() {
            var channel = $('#radio-channel').val();

            if (channel.length) {
                this.post('radio:preset_request', [channel]);
                this.settingPreset = true;
            }
        },

        destroy(withoutPost) {
            this.active = false;
            this.settingPreset = false;

            $(".radio-layout").fadeOut(1000);
            
            if (!withoutPost)
                this.post("radio:exit");
        }

    }
})