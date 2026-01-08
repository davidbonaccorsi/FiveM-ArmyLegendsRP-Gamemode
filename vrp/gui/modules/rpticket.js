// const rpTicket = new Vue({
//     el: ".main-rpticket",
//     data: {
//         active: false,
//         zoom: 0,
//     },
//     mounted() {
//         window.addEventListener("message", this.onMessage)
//         window.addEventListener("resize", this.handleResize)
//     },
//     methods: {

//         onMessage() {
//             const data = event.data;

//             if (data.interface == "rpticket")
//                 this.build();
//         },

// 		async post(url, data = {}) {
// 			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
// 			    method: 'POST',
// 			    headers: { 'Content-Type': 'application/json' },
// 			    body: JSON.stringify(data)
// 			});
			
// 			return await response.json();
// 		},

//         handleResize() {
//             var zoomCountOne = $(window).width() / 1920;
//             var zoomCountTwo = $(window).height() / 1080;

//             if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
//         },

//         build() {
//             this.active = true;
//             $(".main-rpticket").fadeIn(1000);
//             var audio = new Audio("../public/sounds/rpticket.ogg")
//             audio.volume = 1.0;
//             audio.play();
//             this.post("setFocus", [true]);
//         },

//         destroy() {
//             this.active = false;
//             $(".main-rpticket").fadeOut(1000);
//             this.post("setFocus", [false]);
//         }
//     }
// })
