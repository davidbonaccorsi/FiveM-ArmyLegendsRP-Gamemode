var otherInvData
var playerItems
var otherItems
var otherInventoryType

var playerItemsArray

var playerWeight
var otherWeight
var playerMaxWeight
var otherInventoryMaxWeight
var hasBag

var policeItems = {
    'weapon_glock17': true,
    'weapon_m9': true,
    'weapon_m4': true,
    'weapon_scarh': true,
    'weapon_ar15': true,
    'weapon_mk14': true,
    'weapon_remington': true,
    'weapon_flashlight': true,
    'weapon_nightstick': true,
    'ammo_9mm_pd': true,
    'ammo_762_pd': true,
    'ammo_556_pd': true,
    'ammo_45acp_pd': true,
}

var playerClothes = [
    { drawable: 'mask', name: "Masca", img: "mask.svg" },
    { drawable: 'gat', name: "Esarfa", img: 'scarfs.svg' },
    // { drawable: 'backpack', name: "Ghiozdan", img: 'backpack.svg' },
    { drawable: 'vests', name: "Vesta", img: 'vests.svg' },
    { drawable: 'glasses', name: "Ochelari", img: 'glasses.svg' },
    { drawable: 'watches', name: "Ceas", img: 'watches.svg' },
    { drawable: 'hats', name: "Palarie", img: 'hats.svg' },
    { drawable: 'top', name: "Hanorace", img: 'hanorace.svg' },
    { drawable: 'undershirt', name: "Tricou", img: 'shirts.svg' },
    { drawable: 'pants', name: "Pantaloni", img: 'pants.svg' },
    { drawable: 'shoes', name: "Papuci", img: 'shoes.svg' },
    { drawable: 'earings', name: "Cercei", img: 'earings.svg' },
    { drawable: 'gloves', name: "Manusi", img: 'gloves.svg' },
    { drawable: 'gat', name: "Lant", img: 'neckless.svg' },
    // { drawable: 'bratara', name: "Bratara", img: 'noimg.svg' },
    // { drawable: 'none', name: "none", img: 'noimg.svg' },
]

const specialImgs = {
    ['_scope']: 'scope',
    ['_clip']: 'clip',
    ['_supressor']: 'supressor',
    ['_flash']: 'flash',
    ['_grip']: 'grip',
    ['_skin']: 'skin',
}

function getCorrectImage(itemid) {
    if (itemid == undefined) return itemid;
    findSpecialImg = function (image) {
        for (code in specialImgs) {
            if (image.search(code) != -1)
                return specialImgs[code];
        }
        return null;
    }
    let image = findSpecialImg(itemid) || itemid;
    return image;
}

function  calculatePercentage(startTimestamp, endTimestamp, hours) {
    const millisecondsPerMinute = 60 * 1000;
    const millisecondsPerSecond = 1000;
  
    const timeDifference = endTimestamp - startTimestamp;
  
    const minutesLeft = Math.floor(timeDifference / millisecondsPerMinute);
    const secondsLeft = Math.floor((timeDifference % millisecondsPerMinute) / millisecondsPerSecond);
  
    const totalSeconds = minutesLeft * 60 + secondsLeft;
  
    // Calculate the percentage
    const percentage = (totalSeconds / (hours * 3600)) * 100; // Assuming the total time is 1 hour (60 minutes)
    const clampedAscendingPercentage = Math.max(0, Math.min(100, percentage));

    return clampedAscendingPercentage;
};

function refreshInventoryWeight(other) {
    post('getWeight').then((data) => {
        if (other && otherItems !== null) {
            otherWeight = data.otherWeight
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .title-wrapper .space-data p').text(otherWeight.toFixed(1))
        }

        playerWeight = data.playerWeight
        $('.inventory-layout > .inventories-list > .the-items.player-pocket .title-wrapper .space-data p').text(playerWeight.toFixed(1) + '/' + playerMaxWeight.toFixed(1) + ' KG')
    })
}

const trimNumber = number => number >= 99 ? '99+' : number;

var inventory = {
    active: false,
    
    playerBackpack: $(".player-backpack > .items-wrapper > .list"),
    playerPocket: $(".player-pocket > .items-wrapper > .list"),
    playerOther:  $(".player-other > .items-wrapper > .list"),
    wardrobe: $(".inventory-layout > .wardrobe .clothes-wrapper"),

    fastSlots: $(".inventory-layout > .fast-slots"),
    fastSlotsList: $(".inventory-layout > .fast-slots > .slots"),

    loadInventory: function(data) {
        otherInvData = data.other && data.other.chestData
        otherInventoryType = data.other && data.other.type
        playerItems = data.player.items
        otherItems = data.other && data.other.items || {}
        playerMaxWeight = data.player && data.player.maxWeight
        hasBag = data.player && data.player.hasBag
        var fastSlotsItems = Object.values(data.player && data.player.fastSlots || {})

        this.playerPocket.html('')
        this.playerBackpack.html('')
        this.playerOther.html('')
        this.fastSlotsList.html('')

        for (i = 1; i < 42; i++) {
            if (i >= 1 && i < 7) {
                this.playerPocket.append(`<div data-slot="${i}" class="item empty disable-context"><h1>?</h1></div>`);
            } else if (i >= 7 && i < 12){
                continue
            } else {
                this.playerBackpack.append(`<div data-slot="${i}" class="item empty disable-context"><h1>?</h1></div>`);
            }
        }

        for (const index in playerItems) {
            let data = playerItems[index]

            if (data && data !== undefined) {
                if (data.slot >= 7 && data.slot < 12) continue 

                let obj = $(`.item[data-slot="${parseInt(data.slot)}"]`)
                obj.data({'item': data.item, 'expire': data.extraData && data.extraData.expire || 0, 'amount': data.amount, 'label': data.label, 'description': data.description, 'weight': data.weight, 'isUnique': data.isUnique, 'currentUsage': data.currentUsage | 0, 'maxUsage': data.maxUsage | 100}).html(`
                    <img src="https://cdn.armylegends.ro/items/${data.item}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                    <div class="item-amount">${trimNumber(parseInt(data.amount))}</div>
                `).addClass('usable-item').removeClass('empty disable-context')
            }
        }


        for (let i = 7; i < 12; i++) {
                let data = fastSlotsItems.find(data => data && data.slot === i)

                if (data && data !== undefined) {
                    let image = getCorrectImage(data.item);
                    this.fastSlotsList.append(`
                        <div class="box" data-slot="${i}" data-inventory="fast">
                            <div data-item="${data.item}" data-expire="${data.extraData && data.extraData.expire || 0}" data-amount="${data.amount}" data-weight="${data.weight}" data-isUnique="${data.isUnique || false}" data-currentUsage="${data.currentUsage}" data-maxUsage="${data.maxUsage}" data-label="${data.label}" data-description="${data.description}" class="item">
                                <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'"></img>
                            </div>
                            <div class="key">
                               <div class="text">${i - 6}</div>
                            </div>
                        </div>
                    `).addClass('usable-item').data({ 'item': data.item, 'expire': data.extraData.expire, 'amount': data.amount, 'label': data.label, 'description': data.description, 'weight': data.weight, 'isUnique': data.isUnique, 'currentUsage': data.currentUsage | 0, 'maxUsage': data.maxUsage | 100 })
                } else {
                    this.fastSlotsList.append(`
                        <div class="box" data-slot="${i}" data-inventory="fast">
                            <div class="item"></div>
                            <div class="key">
                               <div class="text">${i - 6}</div>
                            </div>
                        </div>
                    `)
                }
            }

        if (data && data.player && data.player.hasBag) {
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .items-wrapper').removeClass('locked')
        } else {
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .items-wrapper').addClass('locked')
        }

        $('.player-pocket').addClass('notvisible')
        $('.player-backpack').addClass('notvisible')
        $('.player-other').addClass('notvisible')
        
        if (data && data.other) {
            this.playerOther.data('inventory', data.other.type)

            $('.player-other').removeClass('notvisible')
            $('.player-pocket').removeClass('notvisible')
            $('.player-backpack').removeClass('notvisible')
            $('.wardrobe').removeClass('visible')

            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .title-wrapper .title.chest').text(data.other && data.other.name.toUpperCase() || '')
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .items-wrapper.locked .locked-status').css('left', '12%')
            $('.inventory-layout > .inventories-list').css('right', '10%')

            otherInventoryMaxWeight = data.other && data.other.maxWeight
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .title-wrapper .weight-data .weight p').text('/ ' + data.other.maxWeight.toFixed(1) + ' KG')
            refreshInventoryWeight(true)

            for (i = 1; i < 31; i++) {
                this.playerOther.append(`<div data-slot="${i}" class="item empty disable-context"><h1>?</h1></div>`);
            }

            for (const index in otherItems) {
                let data = otherItems[index]

                if (data && data !== undefined) {
                    let obj = $('.player-other > .items-wrapper > .list .item').filter(`[data-slot=${data.slot}]`);

                    obj.data({'item': data.item, expire: data.extraData && data.extraData.expire || 0, 'amount': data.amount, 'label': data.label, 'description': data.description, 'weight': data.weight, 'isUnique': data.isUnique, 'currentUsage': data.currentUsage | 0, 'maxUsage': data.maxUsage | 100}).html(`
                        <img src="https://cdn.armylegends.ro/items/${data.item}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                        <div class="item-amount">${trimNumber(parseInt(data.amount))}</div>
                    `).removeClass('empty disable-context')
                }
            }

        } else {
            $('.inventory-layout > .inventories-list > .other-inv-wrapper > .the-items .items-wrapper.locked .locked-status').css('left', '25%')
            $('.inventory-layout > .inventories-list').css('right', '45%')
            
            $('.wardrobe').addClass('visible')
            this.animSiluete();
        }

        $(".item").draggable({ helper: 'clone', containment: 'window', scroll: false });

        $(".item").droppable({
            drop: async function (event, ui) {
                const from = ui.draggable.parent().data('inventory');
                const to = $(this).parent().data('inventory');

                const fromSlot = ui.draggable.data('slot')
                const toSlot = $(this).data('slot')

                if (from == 'fast' && to == 'backpack' || from == "fast" && to == 'pocket') {
                    const amount = ui.draggable.data('amount')
                    const item = ui.draggable.data('item')
                    const label = ui.draggable.data('label')
                    const description = ui.draggable.data('description')
                    const weight = ui.draggable.data('weight')
                    const isUnique = ui.draggable.data('isUnique')
                    const currentUsage = ui.draggable.data('currentUsage')
                    const maxUsage = ui.draggable.data('maxUsage')
                    const expire = ui.draggable.data('expire')
                    const fastSlot = $(this).parent().data('slot')
                    let image = getCorrectImage(item);
                    if (!item) return;
                    if (inventory)

                        if (to == 'backpack' && !hasBag) return serverHud.sendError('Nu ai un ghiozdan echipat!', 1000)
                    if ($(this).hasClass('usable-item')) return serverHud.sendError('Slotul este deja ocupat!', 1200);
                    const fromSlot = ui.draggable.parent().data('slot')
                    ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null })
                    $(this).html('').append(`
                            <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                            <div class="item-amount">${trimNumber(parseInt(amount))}</div>
                        `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
                    post('inventory:removeSlot', {
                        item: item,
                        slot: fromSlot,
                        toSlot: toSlot,
                    })

                } else if (from == 'backpack' && to == 'fast' || from == 'pocket' && to == 'fast') {
                    const amount = ui.draggable.data('amount')
                    const item = ui.draggable.data('item')
                    const label = ui.draggable.data('label')
                    const description = ui.draggable.data('description')
                    const weight = ui.draggable.data('weight')
                    const isUnique = ui.draggable.data('isUnique')
                    const currentUsage = ui.draggable.data('currentUsage')
                    const maxUsage = ui.draggable.data('maxUsage')
                    const expire = ui.draggable.data('expire')
                    const fastSlot = $(this).parent().data('slot')
                    let image = getCorrectImage(item);
                    let data = fastSlotsItems.find(data => data && data.slot === fastSlot)
                    if (data !== undefined) return serverHud.sendError('Slotul este deja ocupat!', 1200);
                    if (!item) return;
                    if ($(this).hasClass('usable-item')) return serverHud.sendError('Slotul este deja ocupat!', 1200);
                    ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
                    $(this).html('').append(`
                        <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                    `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })

                    post('inventory:equipSlot', {
                        item: item,
                        slot: fastSlot,
                        fromSlot: fromSlot,
                        amount: amount,
                        item: item,
                        label: label,
                        expire: expire,
                        description: description,
                        weight: weight,
                        currentUsage: currentUsage,
                        maxUsage: maxUsage,
                    })
                } else if (from == 'pocket' && to == 'backpack' || from == 'backpack' && to == 'pocket' || from === to) {
                    if (from == 'fast' || from == 'player-inv' || from == 'glovebox-player' || from == 'trunk-player') return;

                    if (to == 'backpack' && !hasBag) return serverHud.sendError('Nu ai un ghiozdan echipat!', 1000)

                    if ($(this).parent().parent().hasClass('locked')) return;

                    const itemTo = $(this).data('item');
                    const amountTo = $(this).data('amount');
                    const labelTo = $(this).data('label');
                    const descriptionTo = $(this).data('description');
                    const weightTo = $(this).data('weight');
                    const currentUsageTo = $(this).data('currentUsage');
                    const maxUsageTo = $(this).data('maxUsage');
                    const expireTo = $(this).data('expire');
                    const isUniqueTo = $(this).data('isUnique');

                    const amount = ui.draggable.data('amount')
                    const item = ui.draggable.data('item')
                    const label = ui.draggable.data('label')
                    const description = ui.draggable.data('description')
                    const weight = ui.draggable.data('weight')
                    const currentUsage = ui.draggable.data('currentUsage')
                    const expire = ui.draggable.data('expire')
                    const maxUsage = ui.draggable.data('maxUsage')
                    const isUnique = ui.draggable.data('isUnique')
                    let image = getCorrectImage(item);
                    let imageTo = getCorrectImage(itemTo);
                    if (!item) return;
                    if ($(this).hasClass('usable-item')) {
                        ui.draggable.html('').append(`
                                <img src="https://cdn.armylegends.ro/items/${imageTo}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                                <div class="item-amount">${trimNumber(parseInt(amountTo))}</div>
                            `).data({ 'item': itemTo, 'amount': amountTo, 'expire': expireTo, 'label': labelTo, 'description': descriptionTo, 'weight': weightTo, 'isUnique': isUniqueTo, 'currentUsage': currentUsageTo | 0, 'maxUsage': maxUsageTo | 100 })
                    } else {
                        ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
                    }

                    post('inventory:moveItem', {
                        from: from,
                        to: to,
                        item: item,
                        itemTo: itemTo || false,
                        fromSlot: fromSlot,
                        toSlot: toSlot,
                        amount: amount,
                        chestData: otherInvData || false,
                    })
                    // inventory.destroy();
                    $(this).html('').append(`
                        <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                            <div class="item-amount">${trimNumber(parseInt(amount))}</div>
                        `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
                } else {
                    if (from == 'fast' || to == 'fast') return;
                    const amount = ui.draggable.data('amount')
                    const item = ui.draggable.data('item')
                    const label = ui.draggable.data('label')
                    const description = ui.draggable.data('description')
                    const weight = ui.draggable.data('weight')
                    const isUnique = ui.draggable.data('isUnique')
                    const currentUsage = ui.draggable.data('currentUsage')
                    const expire = ui.draggable.data('expire')
                    const maxUsage = ui.draggable.data('maxUsage')
                    let image = getCorrectImage(item);
                    if (!item) return;
                    if (otherItems) {
                        for (var index in otherItems) {
                            let data = otherItems[index];

                            if (data && data.slot) {
                                if (data.slot == toSlot && isUnique) {
                                    return serverHud.sendError('Slotul este deja ocupat!', 1200)
                                } else if (data.slot == toSlot && data.item != item) {
                                    return serverHud.sendError('Slotul este deja ocupat!', 1200)
                        
                                }
                            }
                        }
                    }
                    if (policeItems[item]) return serverHud.sendError('Nu poti muta itemele din inventarul politiei!', 1000)
                    if ($(this).hasClass('usable-item')) {
                        const itemTo = $(this).data('item');
                        if (item !== itemTo) {
                            return
                        }
                    }
                    var itemAmount = amount;
                    if (amount > 1) {
                        let number = await Prompt.build('muti');
                        if (!number) return
                        itemAmount = (number < amount) ? parseInt(number) : itemAmount;
                    }
                    const maxInventorySpace = (from == 'pocket' || from == 'backpack') ? otherInventoryMaxWeight : playerMaxWeight;
                    const userInventorySpace = (from == 'pocket' || from == 'backpack') ? otherWeight : playerWeight;
                    if ((maxInventorySpace - userInventorySpace) - (weight * itemAmount) < 0) {
                        return serverHud.sendError('Nu ai destul spatiu pentru a muta acest item!', 1000)
                    }


                    if (isUnique) {
                        const itemTo = $(this).data('item');
                        if (item === itemTo) return serverHud.sendError('Nu poti muta itemele unice in acelasi slot!', 1000)

                        if (parseInt(amount) - parseInt(itemAmount) <= 0) {
                            ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
                        } else {
                            let nowAmount = ui.draggable.data('amount')
                            let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
                            ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                        }

                        $(this).html('').append(`
                            <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                            <div class="item-amount">${itemAmount}</div>
                        `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': itemAmount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
                    } else if (!isUnique) {
                        if ($(this).hasClass('usable-item') && $(this).data('item') == item) {
                            $(this).children().html('').text(parseInt($(this).data('amount')) + parseInt(itemAmount))

                            if (parseInt(amount) - parseInt(itemAmount) <= 0) {
                                ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
                            } else {
                                let nowAmount = ui.draggable.data('amount')
                                let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
                                ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                            }
                        } else if ($(this).hasClass('usable-item') == false) {
                            post('hasItem', {
                                item: item,
                                to: to,
                            }).then(has => {
                                if (has) {
                                    let slot = has
                                    if (to == 'backpack') {
                                        let obj = $('.player-backpack > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
                                        let nowAmount = obj.children('.item-amount').text()
                                        let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

                                        obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                                    } else if (to == 'pocket') {
                                        let obj = $('.player-pocket > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
                                        let nowAmount = obj.children('.item-amount').text()
                                        let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

                                        obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                                    } else {
                                        let obj = $('.player-other > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
                                        let nowAmount = obj.children('.item-amount').text()
                                        let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

                                        obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                                    }
                                } else {
                                    $(this).html('').append(`
                                        <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
                                        <div class="item-amount">${trimNumber(parseInt(itemAmount))}</div>
                                    `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': itemAmount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
                                }

                                if (parseInt(amount) - parseInt(itemAmount) <= 0) {
                                    ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
                                } else {
                                    let nowAmount = ui.draggable.data('amount')
                                    let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
                                    ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
                                }
                            })
                        }
                    }

                    refreshInventoryWeight(true)
                    post('inventory:moveItem', {
                        from: from,
                        to: to,
                        item: item,
                        fromSlot: fromSlot,
                        toSlot: toSlot,
                        amount: itemAmount,
                        chestData: otherInvData || false,
                    })

                    if (to == 'backpack' || to == 'pocket') {
                        $(this).removeClass('empty disable-context')
                    }
                    inventory.destroy();
                }
            }
        });
    },

    openInventory : function(data) {
        if (data && data.player) {
            refreshInventoryWeight(false)
            this.active = true;
            $('.inventory-layout').show()
            post('setFocus', [true])
            
            this.wardrobe.html('')

            this.loadInventory(data)

            this.wardrobe.append(`<div class='row first-column' data-inventory="clothes"></div>`)
            this.wardrobe.append(`<div class='row first-two' data-inventory="clothes"></div>`)
            this.wardrobe.append(`<div class='row first-three' data-inventory="clothes"></div>`)

            for (let i = 0; i < playerClothes.length; i++) {
                let targetClass;

                if (i < 6) {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-column'
                } else if (i >= 8 && i < 13) {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-two'
                } else {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-three'
                }

                if (targetClass) {
                    $(targetClass).append(`
                        <div class='box' data-nume="${playerClothes[i].name}"  data-drawable="${playerClothes[i].drawable}"> 
                            <img src="https://cdn.armylegends.ro/inventory/${playerClothes[i].img}">
                            <p>${playerClothes[i].name}</p>
                         </div>
                    `)
                }
            }

            $('.inventory-layout > .wardrobe .clothes-wrapper .row .box').on('click', function() {
                let drawable = $(this).data('drawable')
                
                post('inventory:changeVariation', [drawable])
            })
                        
            $('.inventory-layout > .wardrobe .clothes-wrapper .row.first-column').append('<div class="spacer"></div>')
        }  
    },

    //     $(".item").droppable({
    //         drop: async function (event, ui) {
    //             const from = ui.draggable.parent().data('inventory');
    //             const to = $(this).parent().data('inventory');

    //             const fromSlot = ui.draggable.data('slot')
    //             const toSlot = $(this).data('slot')

    //             if (from == 'fast' && to == 'backpack' || from == "fast" && to == 'pocket') {
    //                 const amount = ui.draggable.data('amount')
    //                 const item = ui.draggable.data('item')
    //                 const label = ui.draggable.data('label')
    //                 const description = ui.draggable.data('description')
    //                 const weight = ui.draggable.data('weight')
    //                 const isUnique = ui.draggable.data('isUnique')
    //                 const currentUsage = ui.draggable.data('currentUsage')
    //                 const maxUsage = ui.draggable.data('maxUsage')
    //                 const expire = ui.draggable.data('expire')
    //                 const fastSlot = $(this).parent().data('slot')
    //                 let image = getCorrectImage(item);
    //                 if (!item) return;
    //                 if (inventory)

    //                     if (to == 'backpack' && !hasBag) return serverHud.sendError('Nu ai un ghiozdan echipat!', 1000)
    //                 if ($(this).hasClass('usable-item')) return serverHud.sendError('Slotul este deja ocupat!', 1200);
    //                 const fromSlot = ui.draggable.parent().data('slot')
    //                 ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null })
    //                 $(this).html('').append(`
    //                         <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                         <div class="item-amount">${trimNumber(parseInt(amount))}</div>
    //                     `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
    //                 post('inventory:removeSlot', {
    //                     item: item,
    //                     slot: fromSlot,
    //                     toSlot: toSlot,
    //                 })

    //             } else if (from == 'backpack' && to == 'fast' || from == 'pocket' && to == 'fast') {
    //                 const amount = ui.draggable.data('amount')
    //                 const item = ui.draggable.data('item')
    //                 const label = ui.draggable.data('label')
    //                 const description = ui.draggable.data('description')
    //                 const weight = ui.draggable.data('weight')
    //                 const isUnique = ui.draggable.data('isUnique')
    //                 const currentUsage = ui.draggable.data('currentUsage')
    //                 const maxUsage = ui.draggable.data('maxUsage')
    //                 const expire = ui.draggable.data('expire')
    //                 const fastSlot = $(this).parent().data('slot')
    //                 let image = getCorrectImage(item);
    //                 let data = fastSlotsItems.find(data => data && data.slot === fastSlot)
    //                 if (data !== undefined) return serverHud.sendError('Slotul este deja ocupat!', 1200);
    //                 if (!item) return;
    //                 if ($(this).hasClass('usable-item')) return serverHud.sendError('Slotul este deja ocupat!', 1200);
    //                 ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
    //                 $(this).html('').append(`
    //                     <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                 `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })

    //                 post('inventory:equipSlot', {
    //                     item: item,
    //                     slot: fastSlot,
    //                     fromSlot: fromSlot,
    //                     amount: amount,
    //                     item: item,
    //                     label: label,
    //                     expire: expire,
    //                     description: description,
    //                     weight: weight,
    //                     currentUsage: currentUsage,
    //                     maxUsage: maxUsage,
    //                 })
    //             } else if (from == 'pocket' && to == 'backpack' || from == 'backpack' && to == 'pocket' || from === to) {
    //                 if (from == 'fast' || from == 'player-inv' || from == 'glovebox-player' || from == 'trunk-player') return;

    //                 if (to == 'backpack' && !hasBag) return serverHud.sendError('Nu ai un ghiozdan echipat!', 1000)

    //                 if ($(this).parent().parent().hasClass('locked')) return;

    //                 const itemTo = $(this).data('item');
    //                 const amountTo = $(this).data('amount');
    //                 const labelTo = $(this).data('label');
    //                 const descriptionTo = $(this).data('description');
    //                 const weightTo = $(this).data('weight');
    //                 const currentUsageTo = $(this).data('currentUsage');
    //                 const maxUsageTo = $(this).data('maxUsage');
    //                 const expireTo = $(this).data('expire');
    //                 const isUniqueTo = $(this).data('isUnique');

    //                 const amount = ui.draggable.data('amount')
    //                 const item = ui.draggable.data('item')
    //                 const label = ui.draggable.data('label')
    //                 const description = ui.draggable.data('description')
    //                 const weight = ui.draggable.data('weight')
    //                 const currentUsage = ui.draggable.data('currentUsage')
    //                 const expire = ui.draggable.data('expire')
    //                 const maxUsage = ui.draggable.data('maxUsage')
    //                 const isUnique = ui.draggable.data('isUnique')
    //                 let image = getCorrectImage(item);
    //                 let imageTo = getCorrectImage(itemTo);
    //                 if (!item) return;
    //                 if ($(this).hasClass('usable-item')) {
    //                     ui.draggable.html('').append(`
    //                             <img src="https://cdn.armylegends.ro/items/${imageTo}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                             <div class="item-amount">${trimNumber(parseInt(amountTo))}</div>
    //                         `).data({ 'item': itemTo, 'amount': amountTo, 'expire': expireTo, 'label': labelTo, 'description': descriptionTo, 'weight': weightTo, 'isUnique': isUniqueTo, 'currentUsage': currentUsageTo | 0, 'maxUsage': maxUsageTo | 100 })
    //                 } else {
    //                     ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
    //                 }

    //                 post('inventory:moveItem', {
    //                     from: from,
    //                     to: to,
    //                     item: item,
    //                     itemTo: itemTo || false,
    //                     fromSlot: fromSlot,
    //                     toSlot: toSlot,
    //                     amount: amount,
    //                     chestData: otherInvData || false,
    //                 })
    //                 // inventory.destroy();
    //                 $(this).html('').append(`
    //                     <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                         <div class="item-amount">${trimNumber(parseInt(amount))}</div>
    //                     `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': amount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
    //             } else {
    //                 if (from == 'fast' || to == 'fast') return;
    //                 const amount = ui.draggable.data('amount')
    //                 const item = ui.draggable.data('item')
    //                 const label = ui.draggable.data('label')
    //                 const description = ui.draggable.data('description')
    //                 const weight = ui.draggable.data('weight')
    //                 const isUnique = ui.draggable.data('isUnique')
    //                 const currentUsage = ui.draggable.data('currentUsage')
    //                 const expire = ui.draggable.data('expire')
    //                 const maxUsage = ui.draggable.data('maxUsage')
    //                 let image = getCorrectImage(item);
    //                 if (!item) return;
    //                 if (otherItems) {
    //                     for (var index in otherItems) {
    //                         let data = otherItems[index];

    //                         if (data && data.slot) {
    //                             if (data.slot == toSlot && isUnique) {
    //                                 return serverHud.sendError('Slotul este deja ocupat!', 1200)
    //                             } else if (data.slot == toSlot && data.item != item) {
    //                                 return serverHud.sendError('Slotul este deja ocupat!', 1200)
                        
    //                             }
    //                         }
    //                     }
    //                 }
    //                 if (policeItems[item]) return serverHud.sendError('Nu poti muta itemele din inventarul politiei!', 1000)
    //                 if ($(this).hasClass('usable-item')) {
    //                     const itemTo = $(this).data('item');
    //                     if (item !== itemTo) {
    //                         return
    //                     }
    //                 }
    //                 var itemAmount = amount;
    //                 if (amount > 1) {
    //                     let number = await Prompt.build('muti');
    //                     if (!number) return
    //                     itemAmount = (number < amount) ? parseInt(number) : itemAmount;
    //                 }
    //                 const maxInventorySpace = (from == 'pocket' || from == 'backpack') ? otherInventoryMaxWeight : playerMaxWeight;
    //                 const userInventorySpace = (from == 'pocket' || from == 'backpack') ? otherWeight : playerWeight;
    //                 if ((maxInventorySpace - userInventorySpace) - (weight * itemAmount) < 0) {
    //                     return serverHud.sendError('Nu ai destul spatiu pentru a muta acest item!', 1000)
    //                 }


    //                 if (isUnique) {
    //                     const itemTo = $(this).data('item');
    //                     if (item === itemTo) return serverHud.sendError('Nu poti muta itemele unice in acelasi slot!', 1000)

    //                     if (parseInt(amount) - parseInt(itemAmount) <= 0) {
    //                         ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
    //                     } else {
    //                         let nowAmount = ui.draggable.data('amount')
    //                         let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
    //                         ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                     }

    //                     $(this).html('').append(`
    //                         <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                         <div class="item-amount">${itemAmount}</div>
    //                     `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': itemAmount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
    //                 } else if (!isUnique) {
    //                     if ($(this).hasClass('usable-item') && $(this).data('item') == item) {
    //                         $(this).children().html('').text(parseInt($(this).data('amount')) + parseInt(itemAmount))

    //                         if (parseInt(amount) - parseInt(itemAmount) <= 0) {
    //                             ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
    //                         } else {
    //                             let nowAmount = ui.draggable.data('amount')
    //                             let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
    //                             ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                         }
    //                     } else if ($(this).hasClass('usable-item') == false) {
    //                         post('hasItem', {
    //                             item: item,
    //                             to: to,
    //                         }).then(has => {
    //                             if (has) {
    //                                 let slot = has
    //                                 if (to == 'backpack') {
    //                                     let obj = $('.player-backpack > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
    //                                     let nowAmount = obj.children('.item-amount').text()
    //                                     let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

    //                                     obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                                 } else if (to == 'pocket') {
    //                                     let obj = $('.player-pocket > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
    //                                     let nowAmount = obj.children('.item-amount').text()
    //                                     let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

    //                                     obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                                 } else {
    //                                     let obj = $('.player-other > .items-wrapper > .list .item').filter(`[data-slot=${parseInt(slot)}]`)
    //                                     let nowAmount = obj.children('.item-amount').text()
    //                                     let updatedAmount = parseInt(nowAmount) + parseInt(itemAmount)

    //                                     obj.data({ 'amount': updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                                 }
    //                             } else {
    //                                 $(this).html('').append(`
    //                                     <img src="https://cdn.armylegends.ro/items/${image}.webp" onerror="this.src='https://cdn.armylegends.ro/inventory/noimg.svg'">
    //                                     <div class="item-amount">${trimNumber(parseInt(itemAmount))}</div>
    //                                 `).addClass('usable-item').data({ 'item': item, 'expire': expire, 'amount': itemAmount, 'label': label, 'description': description, 'weight': weight, 'isUnique': isUnique, 'currentUsage': currentUsage | 0, 'maxUsage': maxUsage | 100 })
    //                             }

    //                             if (parseInt(amount) - parseInt(itemAmount) <= 0) {
    //                                 ui.draggable.removeClass('usable-item').addClass('empty disable-context').html('').data({ 'item': null, 'expire': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'isUnique': null, 'currentUsage': null, 'maxUsage': null }).append('<h1>?</h1>');
    //                             } else {
    //                                 let nowAmount = ui.draggable.data('amount')
    //                                 let updatedAmount = parseInt(nowAmount) - parseInt(itemAmount)
    //                                 ui.draggable.data({ amount: updatedAmount }).children('.item-amount').text(trimNumber(updatedAmount))
    //                             }
    //                         })
    //                     }
    //                 }

    //                 refreshInventoryWeight(true)
    //                 post('inventory:moveItem', {
    //                     from: from,
    //                     to: to,
    //                     item: item,
    //                     fromSlot: fromSlot,
    //                     toSlot: toSlot,
    //                     amount: itemAmount,
    //                     chestData: otherInvData || false,
    //                 })

    //                 if (to == 'backpack' || to == 'pocket') {
    //                     $(this).removeClass('empty disable-context')
    //                 }
    //                 inventory.destroy();
    //             }
    //         }
    //     });
    // },

    openInventory : function(data) {
        if (data && data.player) {
            refreshInventoryWeight(false)
            this.active = true;
            $('.inventory-layout').fadeIn(1000)
            post('setFocus', [true])
            
            this.wardrobe.html('')

            this.loadInventory(data)

            this.wardrobe.append(`<div class='row first-column' data-inventory="clothes"></div>`)
            this.wardrobe.append(`<div class='row first-two' data-inventory="clothes"></div>`)
            this.wardrobe.append(`<div class='row first-three' data-inventory="clothes"></div>`)

            for (let i = 0; i < playerClothes.length; i++) {
                let targetClass;

                if (i < 6) {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-column'
                } else if (i >= 8 && i < 13) {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-two'
                } else {
                    targetClass = '.inventory-layout > .wardrobe .clothes-wrapper .row.first-three'
                }

                if (targetClass) {
                    $(targetClass).append(`
                        <div class='box' data-nume="${playerClothes[i].name}"  data-drawable="${playerClothes[i].drawable}"> 
                            <img src="https://cdn.armylegends.ro/inventory/${playerClothes[i].img}">
                            <p>${playerClothes[i].name}</p>
                         </div>
                    `)
                }
            }

            $('.inventory-layout > .wardrobe .clothes-wrapper .row .box').on('click', function() {
                let drawable = $(this).data('drawable')
                
                console.log(drawable);
                post('inventory:changeVariation', [drawable])
            })
                        
            $('.inventory-layout > .wardrobe .clothes-wrapper .row.first-column').append('<div class="spacer"></div>')
        }  
    },

    destroy: function() {
        if (this.active) {
            $('.inventory-layout').fadeOut(100)
            post('setFocus', [false])
            Prompt.close();
            post('closeInv',  {
                otherData: otherInvData || false,
                otherType: otherInventoryType || false,

            })
            this.active = false
        }
    },

    animSiluete: function() {
        var animSiluet = new ProgressBar.Path('#anim-siluet', {
            easing: 'easeInOut',
            duration: 3000,
        })
        var animSiluet2 = new ProgressBar.Path('#anim-siluet2', {
            easing: 'easeInOut',
            duration: 5000,
        })
        var animSiluet3 = new ProgressBar.Path('#anim-siluet3', {
            easing: 'easeInOut',
            duration: 5000,
        })
        var animSiluet4 = new ProgressBar.Path('#anim-siluet4', {
            easing: 'easeInOut',
            duration: 5000,
        })
        
        animSiluet.set(0.0)
        animSiluet2.set(0.0)
        animSiluet3.set(0.0)
        animSiluet4.set(0.0)
        
        animSiluet.animate(1.0, {
            duration: 2000
        }, function() {
            animSiluet2.animate(1.0, {
                duration: 500
            }, function() {
                animSiluet3.animate(1.0, {
                    duration: 500
                }, function() {
                    animSiluet4.animate(1.0, {
                        duration: 500,
                    })
                })
            }) 
        })
    }
}

const Context = {
    active: false,
    menu: $(".context-menu"),
    actions: $(".context-menu > .wrapper > .actions"),
    itemData: $(".context-menu > .wrapper > .item-data"),

    build(data, item) {
        this.active = [data[0], data[2], item];

        var itemPos = $(item).offset();

        this.itemData.children("h1").text(data[1].toUpperCase() + " (" + data[2] + ")");
        let usesEm = $('.inventory-layout > .context-menu > .wrapper > .item-data > .remaining-use-wrapper .remaining-use')
        usesEm.css('width', data[5] + '%')

        let addedClass = "";
        const classesByUses = [ ["middle", 60], ["low", 30] ];
        for (const useData of classesByUses) {
            usesEm.removeClass(useData[0]);

            if (parseInt(data[5]) <= useData[1])
                addedClass = useData[0];
        }

        if (addedClass.trim().length > 0) {
            usesEm.addClass(addedClass);
        }
        
        var paragraphs = this.itemData.children("p");
        paragraphs.last().text(data[4]);
        if (data[2] >  1) {
            paragraphs.first().text(Math.floor(data[3] * data[2]).toFixed(2) + " KG");
        } else {
            paragraphs.first().text(data[3] + " KG")
        }

        var actionsEnabled = $(item).hasClass("usable-item");
        !actionsEnabled ? this.actions.hide() : this.actions.show();

        this.menu.css("left", itemPos.left + 120 + "px");

        if (data[6] > 29) {
            this.menu.css("top", itemPos.top - 230 + "px");
        } else {
            this.menu.css("top", itemPos.top + 3 + "px");
        }

        this.menu.fadeIn(700);
    },
    async onAct(act) {
        switch(act){
            case "use":
                var [item, amount, itemData] = this.active;
                var slot = itemData.data('slot')
                inventory.destroy();
                if(item === "ghiozdanMare" || item === "ghiozdanMediu" || item === "ghiozdanMic") {
                    console.log(post('canUnequipBag'));
                    if(post('canUnequipBag').then(async (canUnequipBag) => {
                        if(canUnequipBag){
                            return post('useItem', [item, slot])
                        } else {
                            return post('normalNotify', ["Nu poti sa iti dai ghiozdanul jos pentru ca ai iteme in el."])
                        }
                    }));
                } else {
                    post('useItem', [item, slot])
                }
            break

            case "give":
                var [item, amount, itemData] = this.active;
                
                post('hasNearPlayers').then(async (hasPlayers) => {
                    if (!hasPlayers) return serverHud.sendError('Nu ai jucatori in apropiere!', 1000);
                    var amt = (amount > 1) ? await Prompt.build("oferi") : amount;
                    var slot = itemData.data('slot')
                
                    if (amt) {
                        inventory.destroy();
                        post('giveItem', [item, amt, slot])
                    }
                })
            break
            
            case "trash":
                var item = this.active[0];
                var [item, amount, itemData] = this.active;
                var slot = itemData.data('slot')
                var amt = (amount > 1) ? await Prompt.build("distrugi") : amount;

                if(item === "ghiozdanMare" || item === "ghiozdanMediu" || item === "ghiozdanMic") {
                    post('trashGhiozdan')
                }
                
                if (amt){
                    if (amount - amt <= 0) {
                        itemData.removeClass('usable-item').addClass('empty disable-context').html('').data({'item': null, 'amount': null, 'label': null, 'description': null, 'weight': null, 'currentUsage': null, 'maxUsage': null}).append('<h1>?</h1>');
                        } else {
                        let updatedAmount = parseInt(amount) - parseInt(amt)
                        itemData.data({'amount': updatedAmount}).children('.item-amount').text(updatedAmount)
                    } 
                    refreshInventoryWeight(false)
                    post('trashItem', [item, amt, slot])
                }
            break
        }
        this.destroy();
    },
    destroy() {
        this.active = false;
        this.menu.fadeOut(100);
    },
};

Context.actions.on("mousedown", ".action", function(data) {
    data.preventDefault();

    var action = $(this).data("act");

    if (data.which == 1 && action){
        Context.onAct(action);
    }
})

$(document).on("mousedown", ".item", function(data) {
	data.preventDefault();

	if (data.which == 3 && !$(this).hasClass("disable-context") && !Context.active) {
        var item = $(this).data('item')
        var itemUsage = 100;
        const expire = $(this).data('expire')
        const maxUsage = $(this).data('maxUsage')
        const currentUsage = $(this).data('currentUsage')

        if (expire && expire > 0) {
            const expireDate = expire * 1000;
            let currentTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
            itemUsage = calculatePercentage(currentTime, expireDate, 32)
            $('.context-menu .wrapper .item-data .remaining-use-wrapper p').text('Valabilitate')
        } else if (maxUsage && currentUsage){
            itemUsage = 100 - (parseInt(currentUsage) / parseInt(maxUsage) ) * 100
            $('.context-menu .wrapper .item-data .remaining-use-wrapper p').text('Durabilitate')
        } else {
            $('.context-menu .wrapper .item-data .remaining-use-wrapper p').text('Durabilitate') 
        }

        const label = $(this).data('label')
        const description = $(this).data('description')
        const weight = $(this).data('weight')
        const amount = $(this).data('amount')
        const slot = $(this).data('slot')
        
        Context.build([item, label, amount, weight, description, itemUsage, slot], $(this));
	} else if (data.which == 1 && Context.active) {
        Context.destroy();
    }
})

const onKey = (event) => {
    var theKey = event.code;
    if (theKey == "Escape" && inventory.active)
        inventory.destroy();
}

window.addEventListener("keydown", onKey)

const Prompt = {
    active: false,
    menu: $(".inv-prompt-menu"),
    wrapper: $(".inv-prompt-menu > .wrapper"),
    input: $(".inv-prompt-menu > .wrapper > input"),

    build(word = "folosesti") {
        this.wrapper.children("p").text(`Introdu cantitatea pe care vrei sa o ${word} in caseta de mai jos si apoi apasa butonul galben.`);
        
        this.input.val("");

        this.menu.fadeIn(500);
        
        if (Context.active){
            Context.destroy();
        }

        return new Promise((resolve, reject) => {
            Prompt.wrapper.children(".options").on("mousedown", "p", async function(data) {
                data.preventDefault();

                var action = $(this).data("act");
                var amount = Prompt.input.val();
                amount = Math.abs(parseInt(amount));

                if (data.which == 1 && action){
                    Prompt.menu.fadeOut(500);
                    
                    resolve((action == "cancel" || amount.length < 1) ? false : amount);
                }
            })
        })
    },

    close() {
        if (this.active) {
            this.menu.fadeOut();
        }
    }
}

var itemTime = false;
function itemNotify(time = 5000, item = "item", label = "Nedefinit", amount = 1) {
    if (itemTime) {
        clearTimeout(itemTime);
        $(".inventory-notify").hide();
    };

    var sound = new Audio("../public/sounds/itemnotify.mp3");
    sound.volume = 0.8;
    sound.play();

    var el = $(".inventory-notify");

    el.children(".wrap").children(".item-img").children("img").attr("src", `https://cdn.armylegends.ro/items/${item}.webp`);
    el.children(".wrap").children(".right").children(".count").text(`Ai primit: ${amount}x`);
    el.children(".wrap").children(".right").children(".title").text(label);
    
    $(".inventory-notify").fadeIn(1000);

    itemTime = setTimeout(() => {
        $(".inventory-notify").fadeOut(1000);
        clearTimeout(itemTime);
        itemTime = false;
    }, time);
}

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "inventory"){
        if (data.act == 'show') {
            inventory.openInventory(data.data)
        } else if (data.act == 'updateInventory') {
            inventory.loadInventory(data.data)
        } else if (data.act == 'notify') {
            itemNotify(data.time, data.item, data.name, data.amount)
        }
    }
});

