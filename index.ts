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
    app.ports.playSong.subscribe((a) =>
    {
        var element = document.getElementById(a);

        if (element.paused) {
            element.play();
        }
        else
        {
            element.pause();
        }
    });
    app.ports.songStarted.subscribe((a) =>
    {
        var element = document.getElementById(a);

        const audioElements = document.querySelectorAll('audio');

        audioElements.forEach(audio => {
            if (audio === element) {
            }
            else
            {
                audio.pause();
            }
        });

    });
  },
  flags: function () {
    return { dpr: window.devicePixelRatio, windowWidth: window.innerWidth };
  },
};

export default config;
