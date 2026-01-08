// s-a incercat developeala da nu a iesit
// by vali scripter gen nu de mine :()

let actRadioType;
let menuOpenedR = false;
let actTimeOut;

const nextSong = async () => {
    const radioData = await axios.get('http://193.84.64.178:3000/'+actRadioType)
    setTimeout(async() => {
        const data = await radioData.data;
        document.getElementsByClassName('radio-root')[0].innerHTML = `
            <iframe src="https://www.youtube.com/embed/${data.actualSong}?start=${data.secondsElapsed}&autoplay=1" src="" frameborder="0" allowfullscreen></iframe>
        `
        const ms = ((data.musicSeconds-data.secondsElapsed) * 1000);
        actTimeOut = setTimeout(() => {
            nextSong()
        }, ms+520)
    }, 1000)
}

const openRadio = async (radioType) => {
    document.getElementsByClassName('radio-title')[0].innerHTML = `FP:RP Radio - ${radioType}`;
    actRadioType = radioType;
    nextSong()
}

const closeRadio = () => {
    document.getElementsByClassName('radio-title')[0].innerHTML = `FP:RP Radio - Oprit`;
    clearTimeout(actTimeOut);
    document.getElementsByClassName('radio-root')[0].innerHTML = ''
}

window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.type == 'openRadio') {
        if(!menuOpenedR) {
            menuOpenedR = true;
            document.getElementsByClassName('radio-list-wrapper')[0].style.display = 'flex';
        }
    } else if (item.type == 'forceCloseRadio') {
        if(menuOpenedR) {
            menuOpenedR = false;
            $('.radio-list-wrapper').fadeOut(200);
        }
        closeRadio();
    }
});

$(document).on('keydown', function (event) {
    switch (event.keyCode) {
        case 27: // ESC
            if(menuOpenedR) {
                menuOpenedR = false;
                $('.radio-list-wrapper').fadeOut(200);
                $.post('https://vrp/closeRadio', JSON.stringify({}));
            }
        break;
    }
});