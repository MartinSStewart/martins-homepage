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
        console.log(elem);
        if (elem) {
            if (elem.classList[0] === 'shootable') {
                const newElem = document.createElement("span");
                document.body.appendChild(newElem);
                const newspaperSpinning = [
                  { transform: "translateY(0px) rotate(0)" },
                  { transform: "translateY(-100px) rotate(100deg)" },
                  { transform: "translateY(100px) rotate(200deg)" },
                  { transform: "translateY(300px) rotate(300deg)" },
                  { transform: "translateY(600px) rotate(400deg)" },
                ];

                const newspaperTiming = {
                  duration: 2000,
                  iterations: 1,
                };
                elem.style.color = 'transparent';
                elem.classList = "";
                newElem.innerText = elem.innerText;
                const rect = elem.getBoundingClientRect();
                newElem.style = "display:inline-block; color:red; position:relative; top:" + rect.top + "left:" + rect.left;

                newElem.animate(newspaperSpinning, newspaperTiming);
            }
        }
    });
  },
  flags: function () {
    return { dpr: window.devicePixelRatio, windowWidth: window.innerWidth };
  },
};

export default config;
