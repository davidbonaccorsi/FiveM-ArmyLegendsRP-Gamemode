var factionMenu = new Vue({
    el: '.faction-menu-wrapper',
    data: {
        active: false,
        cashMoney: '2 500',
        bankMoney: '2 500',
        members: [],
        ranks: [],
        onlineMembers: 0,
        totalMembers: 0,
        maxSlots: 0,
        balance: 0,
        faction: 'Los Vagos',
        factionLeader: '',
        currentPage: 'members',
        fType: 'Mafia',
        tasks: [],
        factionLevel: [],
        levelProgress: 0,
        membersProgress: 0,
        isLeader: false,

        // Create Rank Menu
        createRankMenu: false,
        
        // Manage Player
        managePlayerMenu: false,
        playerData: [],
        menuRanks: [],
        currentRank: 0,
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
    },
    methods: {
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
        onKey: function() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy(true) 
		},
        formatData: function(timestamp) {
            const date = new Date(timestamp * 1000);
            const options = {
              day: '2-digit',
              month: '2-digit',
              year: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            };
          
            return date.toLocaleString('en-GB', options);
        },
        build: function(data) {
            this.active = true
            this.currentPage = 'main'
            this.cashMoney = data.userData.cash.toLocaleString('en-US', {
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            }).replace(/,/g, ' ');
            this.bankMoney = data.userData.bank.toLocaleString('en-US', {
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            }).replace(/,/g, ' ');
            this.faction = data.faction;
            this.members = data.members;
            this.ranks = data.ranks
            this.menuRanks = data.menuRanks
            this.onlineMembers = data.onlineMembers
            this.totalMembers = data.totalMembers
            this.maxSlots = data.maxSlots
            this.factionLeader = data.factionLeader
            this.balance = data.balance.toLocaleString('en-US', {
                minimumFractionDigits: 0,
                maximumFractionDigits: 0
            }).replace(/,/g, ' ');
            this.fType = data.factionType;
            this.tasks = data.tasks
            this.isLeader = data.isLeader;
            this.factionLevel = data.factionLevel

            this.levelProgress = (this.factionLevel.currentXP / this.factionLevel.nextLevelXP) * 100
            this.membersProgress = (this.totalMembers / this.maxSlots) * 100
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
        },
        destroy: function() {
            if (this.createRankMenu) {
                this.createRankMenu = false
            } else if (this.managePlayerMenu) {
                this.managePlayerMenu = false;
            } else {
                this.active = false
                this.post('setBlur', [false]);
                this.post('setFocus', [false]);
                
                this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
                this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
            }
        },
        changePage: function(page) {
            this.currentPage = page
        },
        formatString: function(str, ...args) {
            return str.replace(/{(\d+)}/g, (match, index) => args[index] || "");
        },
        factionDeposit: function() {
            const amount = $('#faction-menu-bank-amount').val()
            if (amount > 0) {
                this.post('faction:depositMoney', [amount]).then((data) => {
                    this.balance = data.budget.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');
                    this.cashMoney = data.cash.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');
                    this.bankMoney = data.bank.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');

                    $('#faction-menu-bank-amount').val('')
                })
            }
        },
        factionWithdraw: function() {
            // if (!this.isLeader) return
            const amount = $('#faction-menu-bank-amount').val()
            if (amount > 0) {
                this.post('faction:withdrawMoney', [amount]).then((data) => {
                    this.balance = data.budget.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');
                    this.cashMoney = data.cash.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');
                    this.bankMoney = data.bank.toLocaleString('en-US', {
                        minimumFractionDigits: 0,
                        maximumFractionDigits: 0
                    }).replace(/,/g, ' ');
                    $('#faction-menu-bank-amount').val('')
                })
            }
        },
        invitePlayer: function() {
            if (!this.isLeader) return;
            this.post("vrp:triggerServerEvent", ['vrp-factions:inviteMember']);
        },

        // Create Rank Menu
        createRank: function() {
            if (!this.isLeader) return
            this.createRankMenu =  true
        },
        confirmCreateRank: function() {
            if (!this.isLeader) return
            const rankName = $('#faction-menu-create-rank').val()
            if (rankName.length > 0) {
                this.post('faction:createRank', [rankName]).then((data) => {
                    $('.faction-menu-wrapper .create-rank-wrapper .create-rank').fadeOut(500, () => {
                        $('.faction-menu-wrapper .create-rank-wrapper').fadeOut(300)
                    })

                    this.post('menu:factionData').then((data) => {
                        if (!data) {
                            this.destroy();
                            return false;
                            // return serverHud.sendError("Nu faci parte dintr-o factiune.");
                        }
    
                        this.build(data);
                    })
                });
                $('#faction-menu-create-rank').val("");
            }
        },
        deleteRank: function(rank) {
            if (!this.isLeader) return
            this.post('faction:deleteRank', [rank]).then((data) => {
                this.post('menu:factionData').then((data) => {
                    if (!data) {
                        this.destroy();
                        return false;
                        // return serverHud.sendError("Nu faci parte dintr-o factiune.");
                    }

                    this.build(data);
                })
            });
        },
        // Manage Player
        managePlayer: function(player) {
            if (!this.isLeader) return
            this.managePlayerMenu = true
            this.playerData = this.members[player]
            let rank = this.playerData.userFaction.rank
            this.currentRank = 0
            
            for (const [index, data] of this.menuRanks.entries()) {
                if (data.rank === rank) {
                    this.currentRank = index
                    break;
                }
            }
        },
        confirmManagePlayer: function() {
            if (!this.isLeader) return
            this.post('faction:managePlayer', [this.playerData.id, this.menuRanks[this.currentRank].rank]).then((done) => {
                if (done) {
                    this.managePlayerMenu = false;

                    this.post('menu:factionData').then((data) => {
                        if (!data) {
                            this.destroy();
                            return false;
                            // return serverHud.sendError("Nu faci parte dintr-o factiune.");
                        }

                        this.build(data);
                    })
                }
            })
        },
        kickPlayer: function() {
            if (!this.isLeader) return
            this.post('faction:kick', [this.playerData.id]).then((done) => {
                // this.members = members
                // this.managePlayerMenu = false
                // $('.faction-menu-wrapper .player-management-wrapper .player-management').fadeOut(500, () => {
                //     $('.faction-menu-wrapper .player-management-wrapper').fadeOut(300)
                // });

                if (done) {
                    this.managePlayerMenu = false;
                    this.post('menu:factionData').then((data) => {
                        if (!data) {
                            this.destroy();
                            return false;
                            // return serverHud.sendError("Nu faci parte dintr-o factiune.");
                        }
    
                        this.build(data);
                    })
                }
            })
        },
        nextRank: function() {
            if (this.currentRank < this.menuRanks.length - 1) {
                this.currentRank++
            }
        },
        previousRank: function() {
            if (this.currentRank > 0) {
                this.currentRank--
            }
        },
    },
});