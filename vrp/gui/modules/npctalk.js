const dialogPeds = {
	layout: $(".main-npctalk"),
	title: $(".main-npctalk > .npctalk-flex > .npc-box > .npc-name"),
	response: $(".main-npctalk > .npctalk-flex > .npc-box > .npc-response"),
	buttons: $(".main-npctalk > .npctalk-flex > .npc-box > .npc-choices"),
	evtargs: {},
	active: false,

	build(data) {
		const pedId = data.pedId;

		this.title.text(data.name);

		this.response.text(data.description || 'Bun venit pe la mine! Cu ce te-as putea ajuta?');
		this.buttons.find("div").remove();

		var em = this.buttons;
		this.evtargs = {};
		$.each(data.buttons, function(k, v){
			em.append(`
				<div data-pedId="${pedId}" data-button="${k}" data-response="${(typeof(v.response) == 'object' && 'function' || v.response)}" ${v.question ? "data-question='"+v.question+"'" : ""} ${v.post ? "data-post='"+v.post+"'" : ""}>
					<p>${v.text}</p>
				</div>
			`);

			if (v.response) dialogPeds.evtargs[v.response] = v.args || {};
		})

		this.layout.fadeIn(1000);
		this.active = true;

	},

	destroy() {
		this.layout.fadeOut(1000);
		this.active = false;
		post("closePedDialog");
	},


	ready() {
		var data = this;
	
		this.buttons.on("click", "div", async function(event) {
			var response = $(this).data("response");

			if (response.startsWith('post:')){
				var args = data.evtargs[response] || {};

				response = response.replace("post:", "");

				var type = response.startsWith("client:") ? "client" : "server";
				
				response = response.replace(type+":", "");
				
				post("selectDialogBtn", [response, type, args])
				
				data.destroy();
			} else if (response == 'function') {
				let question = $(this).data("button");
				let pedId = $(this).data("pedid");
				let [reply, closeAfter] = await post('getResponse', [question, pedId]);

				if (closeAfter) return data.destroy();
				if (reply) data.response.text(reply);
			} else {
				var clientPost = $(this).data("post");
				
				data.response.text(response);

				if (clientPost){
					post(clientPost);
				}

			}

		})
		
	}

};

dialogPeds.ready();

window.addEventListener("keydown", function(event) {
	var theKey = event.code;

	if (theKey == "Escape" && dialogPeds.active && !hudPrompt.active && !hudSelector.active && !hudDialog.active){
		dialogPeds.destroy();
	}
})

window.addEventListener("message", (event) => {
	const data = event.data;
	
	if (data.interface == "pedDialog")
		dialogPeds.build(data.data);
})
