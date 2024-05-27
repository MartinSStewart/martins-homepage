function drawStuff() {
	"use strict";	 
	ctx.fillStyle = 'white';
	ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
	var speed = 400
	for (var i = 0; i < 10; i++)
	{
		ctx.beginPath();
		var a = ((frameCount+i*10) % speed)-speed/2;
		if (a != 0)
		{
			ctx.arc(centerX-1000/a + width*a/50, centerY, Math.abs(1000/a), 2*Math.PI, 0);
		}
		else
		{
			ctx.moveTo(centerX,0);
			ctx.lineTo(centerX,canvas.height);
		}
		ctx.stroke();
	}
	var a = speed/2;
	ctx.beginPath();
	ctx.arc(centerX-1000/a + width*a/50, centerY, Math.abs(1000/a), 2*Math.PI, 0);
	ctx.stroke();
	var a = -speed/2;
	ctx.beginPath();
	ctx.arc(centerX-1000/a + width*a/50, centerY, Math.abs(1000/a), 2*Math.PI, 0);
	ctx.stroke();
	
}
function gameLoop() {
	"use strict";
	drawStuff();
	frameCount ++;
}
var canvas = document.getElementById('canvas');
var ctx = canvas.getContext('2d');
var width = 20;
var gameDelay = 1000/30;
var frameCount = 0;
var centerX = canvas.width/2;
var centerY = canvas.height/2;
var timer = setInterval(function() {
"use strict";
gameLoop();
},gameDelay);