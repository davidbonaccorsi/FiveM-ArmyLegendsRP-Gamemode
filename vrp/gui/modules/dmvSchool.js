new Vue({
    el: ".dmv-layout",

    data: {
        active: false,
        question: 0,
        correct: 0,
        wrong: 0,
        responded: -1,
        dmvQuestions: [
            ["Care este viteza maxima permisa unui cetatean pe drumurile nationale, autostrazi si in oras?", ["150 KM/H, 100 KM/H, 60 KM/H", "120 KM/H, 100 KM/H, 60 KM/H", "60 KM/H, 150 KM/H, 100 KM/H", "100 KM/H, 150 KM/H, 70 KM/H"], 4],
            ["In care dintre urmatoarele situatii ai voie sa iti parchezi autovehiculul langa o bordura si ce reprezinta bordura rosie?", ["Am voie sa parchez cand vreau eu, daca ma asigur ca bordura este rosie, deoarece aceasta reprezinta permiterea parcarii.", "Nu am voie sa parchez pe bordura dar aceasta nu reprezinta nimic.", "Am voie sa parchez langa o bordura doar atunci cand aceasta nu este rosie pentru ca reprezinta parcarea interzisa.", "Este o intrebare capcana, pot sa parchez langa o bordura indiferent daca este rosie sau galbena."], 2],
            ["In care dintre urmatoarele zone poti claxona intr-un mod excesiv, fie pentru a atrage atentia asupra ta, fie pentru a enerva cetatenii orasului?", ["Am voie sa claxonez ecesiv unde vreau eu, ca sunt smecher!", "Nu am voie sa claxonez intr-un mod excesiv nicaieri.", "Pot sa claxonez excesiv langa spital, la sectia de politie si langa casele oamenilor.", "Am voie sa claxonez excesiv doar in zone nepopulate."], 2],
            ["Este permisa inlocuirea geamurilor unui autovehicul cu geamuri fumurii?", ["Da, normal ca este permisa.", "Cred ca este permisa, nu sunt sigur/a.", "Este permisa doar inlocuirea acestora cu geamuri rosii.", "Nu, nu este permisa inlocuirea geamurilor unui autovehicul cu unele fumurii."], 4],
            ["Este permisa modificarea autovehiculelor prin montarea neoanelor sub acestea?", ["Nu, este interzisa montarea neoanelor si se pedepseste cu o amenda de 10.000$", "Nu, este interzisa montarea neoanelor si se pedepseste cu o amenda de 5.000$", "Nu, am voie sa imi pun ce vreau eu pe masina mea!", "Da, este interzisa si nu se sanctioneaza."], 2],
            ["Care dintre urmatoarea categorie de autovehicule are permisiunea de a nu respecta culoarea rosie a semaforului?", ["Masinile de politie si ambulanta.", "Masinile de politie si ambulanta (doar in cazul in care au sirenele si luminile pornite)", "Nimeni nu are voie sa ignore culoarea rosie a semaforului.", "Masina mea personala, doar daca ma grabesc sa ajung undeva."], 2],
            ["In care dintre urmatoarele situatii aveti dreptul de a nu respecta marcajele rutiere?", ["Trebuie sa respect mereu marcajele rutiere.", "Pot sa ignor marcajele rutiere atunci cand vizibilitatea este redusa.", "Pot sa nu respect marcajele rutiere cand vreau eu, ca sunt tare.", "Nu scrie in codul penal, n-am de unde sa stiu."], 1],
            ["Va este permisa acoperirea fetei cu o masca, bandana sau orice alt obiect care ar putea face asta in timpul conducerii unui autovehicul?", ["Da, normal.", "Posibil, nu sunt sigur.", "Este interzisa purtarea unui obiect care acopera fata la volan.", "Dau la noroc si vad la final daca trec sau nu."], 3],
            ["Este permisa utilizarea NOS-ului pe drumurile publice?", ["Da, daca il folosesc cu grija.", "Da, este permisa utilizarea pe orice drum.", "Nu este permisa utilizarea NOS-ului pe drumurile ascunse.", "Nu este permisa utilizarea NOS-ului pe drumurile publice."], 4],
            ["Va este permis sa fugiti de un organ de politie in trafic?", ["Nu, nu este permisa fuga.", "Da, cred ca este permisa.", "Pot sa fug de un politist doar daca am o masina puternica.", "Nu stiu ce raspuns sa dau, vreau sa vad daca am picat sau nu."], 1],
        ],
    },

    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
    },

    methods: {
    
        onMessage(e) {
            const data = e.data;

            if (data.target === 'drivingSchool')
                this.build();
        },

		onKey(e) {
			var theKey = e.code;

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

        build() {
            this.active = true;
            this.correct = 0;
            this.wrong = 0;
            this.responded = -1;
            this.question = 0;

            setTimeout(() => {
                $(".dmv-layout").fadeIn();

                this.post("setFocus", [true]);

                this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
                this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
            }, 256)
            
        },
        choose(index) {
            if (this.responded != -1)
                return false;
            
            this.responded = index;

            setTimeout(() => {
                this.responded != (this.dmvQuestions[this.question][2] - 1) ? this.wrong++ : this.correct++;

                if (this.question + 1 > this.dmvQuestions.length - 1)
                    return this.destroy();

                this.question++;
                this.responded = -1;
            }, 500);
        },

        destroy() {
            this.active = false;
            this.post("setFocus", [false]);

            this.post("completeDmv", [this.correct >= 8]);
        
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);

            $(".dmv-layout").fadeOut();
        },
    },
})