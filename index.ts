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
  },
  flags: function () {
    return { dpr: window.devicePixelRatio, windowWidth: window.innerWidth };
  },
};

export default config;
