type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

async function loadAudio(url, context, sounds) {
    try {
        const response = await fetch("/secret-santa-game/audio/" + url + ".wav");
        const responseBuffer = await response.arrayBuffer();
        sounds[url] = await context.decodeAudioData(responseBuffer);
    } catch (error) {
        console.log(error);
        sounds[url] = null;
    }
}


const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    app.ports.skipForwardVideo.subscribe((a) =>
    {
        document.querySelectorAll('video').forEach(video => {
            if (!video.paused) {
                video.currentTime += 5;
            }
        });
    });
    app.ports.skipBackwardVideo.subscribe((a) =>
    {
        document.querySelectorAll('video').forEach(video => {
            if (!video.paused) {
                video.currentTime -= 5;
            }
        });
    });
    app.ports.getDevicePixelRatio.subscribe((a) =>
    {
        app.ports.gotDevicePixelRatio.send(window.devicePixelRatio);
    });
    let context = null;
    let sounds = {};
    app.ports.loadSounds.subscribe((a) => {
        context = new AudioContext();
        loadAudio("sn_handgun_voice", context, sounds);
        loadAudio("sn_handgun", context, sounds);
        loadAudio("sn_machinegun_voice", context, sounds);
        loadAudio("sn_machinegun", context, sounds);
        loadAudio("sn_shotgun_voice", context, sounds);
        loadAudio("sn_shotgun", context, sounds);
        loadAudio("sn_empty", context, sounds);
        loadAudio("sn_bomb_voice", context, sounds);
    });
    app.ports.playSound.subscribe((a) => {
        const source = context.createBufferSource();
        if (sounds[a]) {
            source.buffer = sounds[a];
            source.connect(context.destination);
            source.start(0);
        }
    });
    app.ports.shoot.subscribe((a) => {

        const elem = document.elementFromPoint(a.x, a.y);
        if (elem) {
            if (elem.classList[0] === 'shootable') {
                let keyframes = [];

                const scale = elem.innerText.length + 3;
                const height = document.documentElement.scrollHeight - elem.getBoundingClientRect().y;

                const xSpeed = (Math.random() - 0.5) * 5 / scale;
                const ySpeed = Math.abs(xSpeed * 2);
                const spinSpeed = (Math.random() - 0.5) * 10 / scale;
                const gravity = -0.001;

                const apexTime = -ySpeed / (2 * gravity);
                const apexHeight = gravity * Math.pow(apexTime, 2) + ySpeed * apexTime + height;

                const timeFactor = 0.03;
                const duration = apexTime + Math.sqrt(-apexHeight / gravity);
                const iterations = 20;

                for (let i = 0; i <= iterations; i++) {
                    const t = duration * i / iterations;
                    const y = -gravity * Math.pow(t, 2) + t * -ySpeed;
                    const x = t * xSpeed;
                    keyframes.push({ color: "inherit", transform: "translateX(" + x + "px) translateY(" + y + "px) rotate(" + (t * spinSpeed) + "deg)" });
                }

                elem.style = "display:inline-block; color:transparent; pointer-events:none";

                elem.animate(keyframes, { duration: duration, iterations: 1 });
            }
        }
    });
  },
  flags: function () {
    return { dpr: window.devicePixelRatio, windowWidth: window.innerWidth };
  },
};

export default config;
