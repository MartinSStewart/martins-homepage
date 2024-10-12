type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

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
    app.ports.shoot.subscribe((a) => {

        const elem = document.elementFromPoint(a.x, a.y);
        if (elem) {
            if (elem.classList[0] === 'shootable') {
                let keyframes = [];

                const scale = elem.innerText.length + 3;
                const bodyHeight = document.documentElement.scrollHeight
                const height = bodyHeight - elem.getBoundingClientRect().y;

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


                elem.classList = "";

                elem.style = "display:inline-block; color:transparent";

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
