const adminTickets = new Vue({
    el: ".admin-tickets-layout",
    data: {
        active: false,
        page: 1,
        subject: "Questions",
        description: "",
        tickets: [],
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

            if (data.interface == "adminTickets") {
                
                if (data.event == "createTicket"){
                    this.build(1, {admin: false});

                } else if (data.event == "ticketsList") {
                    this.build(2, data.data);

                } else if (data.event == "newTicketAlert") {
                    $(".admintk-alert-layout").fadeIn();
                    soundManager.play("taxi-newcall", 0.05);

                    setTimeout(() => {
                        $(".admintk-alert-layout").fadeOut();
                    }, 3500);
                }
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

        build(page, data = false) {
            this.active = true;
            this.page = page;
            if (page == 2) {
                this.tickets = data.tickets;
            }
            data && data.admin ? $('#rampage-hudtickete').fadeIn() : $('#rampage-hudtickete').fadeOut();
            this.post("setFocus", [true]);
        },

        exit() {
            this.destroy();
        },

        confirm() {
            this.post("sendAdminTicket", [this.subject, this.description.trim().length == 0 ? "Problem was not described" : this.description]);
            this.destroy();
        },

        answer(id) {
            this.post("answerAdminTicket", [id]);
            this.destroy();
        },

        skip(id) {
            this.post("skipAdminTicket", [id]);
        },

        setSubject(subject) {
            this.subject = subject;
        },

        destroy() {
            this.active = false;
            this.description = "";
            this.post("setFocus", [false]);
        }
    }
})