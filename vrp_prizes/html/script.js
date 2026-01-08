if (!String.prototype.format) {
    String.prototype.format = function () {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function (match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    };
}


const luckyNumber = 150

var rolled = false;

var isRolling = false;


const possibleItems = [
    "VIP1", "VIP2",
    "Money1", "Money2",
    "Xenon",
    // "WeaponDealer",
    "permisArma",
    "Motocicleta",
    "Masina",
    // "SuperCarY",
    "Coin"
]



function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getPositionOfWinner(winner) {
    var widthOfImg = $('#roulette-img0').width();
    var minDistanceToEdgeAllowed = 4;
    var desiredImg = $('#roulette-img' + winner.toString());
    var minPos = desiredImg.position().left + minDistanceToEdgeAllowed;
    var maxPos = desiredImg.position().left + widthOfImg - minDistanceToEdgeAllowed;
    return getRandomInt(minPos, maxPos);
}

function printLeftOfRouletteSpinner() {
    var pos = $('.roulette-roulette .wrap').position().left;
    if (pos % 100 == 0) console.log(pos);
}

function timelineFinished(){
    const desiredImg = $('#roulette-img' + luckyNumber.toString());
    const middle = desiredImg.position().left + (Math.floor(desiredImg.width()/2))
    var tl = new TimelineMax({ }),
        rouletteImages = $('.roulette-roulette .wrap'),
        startLeft = rouletteImages.position().left;
    tl.to(rouletteImages, 0.7, {x: middle * -1, ease:10000});
    $('.roulette-roulette .wrap .roulette-roulette-item').each(function() {
        if($(this).attr('id') == 'aWinner') {
            $(this).css({'transform': 'scale(115%)'});
        }
    });
    isRolling = false;
}

function generateRouletteObj(type, id) {
    var imgTemplate = '<div class="roulette-roulette-block"> <img src="{0}" class="{1}" id="roulette-img{2}"/></div>';
    var imgClass = 'roulette-img';
    var imgSrcTemplate = 'https://cdn.armylegends.ro/roulette/prizes/{0}.png';
    var imgSrc = imgSrcTemplate.format(type);
    var completedTemplate = imgTemplate.format(imgSrc, imgClass, id);
    return completedTemplate;
}

function rouletteSpin(destImg, winImg) {
    rolled = true;
    if (!destImg) destImg = 40;
    $('#aWinner').html(generateRouletteObj(winImg, luckyNumber));
    var tl = new TimelineMax({ onComplete: timelineFinished }),
        rouletteImages = $('.roulette-roulette .wrap'),
        startLeft = rouletteImages.position().left;
    tl.to(rouletteImages, 10, {x: getPositionOfWinner(destImg) * -1, ease:Power4.easeOut});
    var spinSound = new Audio("spin.mp3");
    spinSound.currentTime = 4;
    spinSound.play();
}

window.addEventListener('message', function(event) {
    if(event.data.type == "toggle") {
        togglePrizes();
    } else if(event.data.type == "spinTo") {
        if(isOpen) rouletteSpin(luckyNumber, event.data.itemId);
    } else if(event.data.type == "setPrice") {
        $('#spin').html(`$${event.data.price}`);
        $('#spinDmd').html(`${event.data.dmdPrice} coins`);
    } else if(event.data.type == "noMoney") {
        isRolling = false;
        if(isOpen) togglePrizes();
    }
});

function getRandomPrize() {
    const randomElement = possibleItems[Math.floor(Math.random() * possibleItems.length)];
    return randomElement;
}

function generateRouletteImages(howMany) {
    var completedRouletteImages = [];
    for (var i = 0; i < howMany; i++) {
        var completedTemplate = generateRouletteObj(getRandomPrize(), i);
        if(i == luckyNumber) {
            completedRouletteImages.push('<div class="roulette-roulette-item" id="aWinner">' + completedTemplate + '</div>');
        } else {
            completedRouletteImages.push('<div class="roulette-roulette-item">' + completedTemplate + '</div>');
        }
    }
    return completedRouletteImages;
}

var isOpen = false;
function togglePrizes() {
    if(isOpen && isRolling) return;
    
    isOpen = !isOpen;
    isRolling = false;
    $('.main-roulette')[isOpen ? "fadeIn" : "hide"]();
    if(isOpen) {
        $('.roulette-roulette .wrap').html(generateRouletteImages(luckyNumber * 2));
        var tl = new TimelineMax({}),
            rouletteImages = $('.roulette-roulette .wrap');
        tl.to(rouletteImages, 0, {x: -1000});
        rolled = false;
    } else {
        $('.roulette-roulette .wrap').empty();
        $.post("http://vrp_prizes/exit");
    }
}

$.each(possibleItems, (k, v) => {
    $(".overflow-list").append(`
        <div class="prize-item">
            <img src="https://cdn.armylegends.ro/roulette/prizes/${v}.png">
        </div>
    `)
})

$('#spin').click(function() {
    if(!isRolling) {
        isRolling = true;
        $.post("http://vrp_prizes/tryGetPrize", 
            JSON.stringify({
                withDmd: false
            })
        );
        if(rolled) {
            $('.roulette-roulette .wrap').html(generateRouletteImages(luckyNumber * 2));
            var tl = new TimelineMax({}),
                rouletteImages = $('.roulette-roulette .wrap');
            tl.to(rouletteImages, 0, {x: -1000});
            rolled = false;
        }
    }
});

$('#spinDmd').click(function() {
    if(!isRolling) {
        isRolling = true;
        $.post("http://vrp_prizes/tryGetPrize", 
            JSON.stringify({
                withDmd: true
            })
        );
        if(rolled) {
            $('.roulette-roulette .wrap').html(generateRouletteImages(luckyNumber * 2));
            var tl = new TimelineMax({}),
                rouletteImages = $('.roulette-roulette .wrap');
            tl.to(rouletteImages, 0, {x: -1000});
            rolled = false;
        }
    }
});

$(".close").click(() => {
    togglePrizes();
});

$('body').keyup(function(e){
    if(isOpen) {
        switch (e.keyCode) {
            case 27: togglePrizes(); // ESC
                break;
            case 80: togglePrizes(); // P - Pause Menu
                break;
        }
    }
});
