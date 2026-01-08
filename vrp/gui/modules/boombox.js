
// todo: de inlocuit xCarRadio cu asta pentru ca e un gunoi
if (false) {

var getYoutubeId = function(url){
    url = url.split(/(vi\/|v%3D|v=|\/v\/|youtu\.be\/|\/embed\/)/);

    if (url[2] !== undefined) {
        return url[2].split(/[^0-9a-z_\-]/i)[0];
    }
    return url[0];
}

var youtubePlayer;
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";

var ytScript = document.getElementsByTagName('script')[0];
ytScript.parentNode.insertBefore(tag, ytScript);

function onYoutubePlayerReady() {
    youtubePlayer.setVolume(20);
}
function onYoutubePlayerStateChange(event) {
    if (event.data == YT.PlayerState.ENDED) {
        boombox.playAlone();
    }
}
function onYoutubePlayerError(event) {
    var errorCode = event.data;

    if (errorCode == 150) {
        serverHud.sendError("Acest link poate fi accesat doar prin YouTube!");
    } else if (errorCode == 2) {
        console.log("[YouTube Player: Boombox]: Id-ul videoclipului pare invalid.")
    }

    boombox.playAlone();
}

function onYouTubeIframeAPIReady()
{
    youtubePlayer = new YT.Player('youtubePlayer', {
        width: '1',
        height: '',
        playerVars: {
            'autoplay': 0,
            'controls': 0,
            'disablekb': 1,
            'enablejsapi': 1,
        },
        events: {
            'onReady': onYoutubePlayerReady,
            'onStateChange': onYoutubePlayerStateChange,
            'onError': onYoutubePlayerError
        }
    });
}

const boombox = {
    loadVideo(id) {
        youtubePlayer.loadVideoById(id, 0, "tiny");
        youtubePlayer.playVideo();
    },

    playAlone(id) {
        this.loadVideo(id);

        var interval = setInterval(() => {
            var videoData = youtubePlayer.getVideoData();

            if (videoData !== undefined) {
                post("boombox:update", {title: videoData.title});
                clearInterval(interval);
            }
        }, 1500);
    },

    playToAll() {
        this.loadVideo(id);
        
        setInterval(() => {
            var videoData = youtubePlayer.getVideoData();

            if (videoData !== undefined) {
                post("boombox:update", {title: videoData.title, toAll: true});
            }
        }, 50000);
    },

    setVolume(volume) {
        youtubePlayer.setVolume(volume);
    },

    stop() {
        youtubePlayer.stopVideo();

        var interval = setInterval(() => {
            var videoData = youtubePlayer.getVideoData();

            if (videoData !== undefined) {
                post("boombox:update", {title: "stop"});
                clearInterval(interval);
            }
        }, 1500);
    }
}

window.addEventListener("message", (event) => {
    const data = event.data;

    if (!(data.interface == "boombox")) return;

    if (data.type == "playUrl") {
        var videoId = getYoutubeId(data.url);
        
        if (data.toAll) {
            boombox.playToAll(videoId);
            return false;
        }
        
        boombox.playAlone(videoId);
    }

    if (data.type == "stopSound") {
        boombox.stop();
    }

    if (data.type == "setVolume") {
        boombox.setVolume(data.volume);
    }
})

}