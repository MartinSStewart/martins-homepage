function drawStuff() {
	"use strict";	 
	var a0 = 41;
	var a1 = 53;
	if (snd.currentTime < a0)
	{
		var color = get_random_value();
		ctx.fillStyle = color;
	}
	else if (snd.currentTime < a1)
	{
		var c = (snd.currentTime - a0)*255/(a1-a0);
		var color = get_rgb(c+Math.pow(c,2)/100,c,c);
		ctx.fillStyle = color
	}
	else
	{
		if (Math.random() > .92 && brightness < frameCount - 10)
		{
			brightness = frameCount;
			cc = Math.random();
			c0 = Math.random()*100+154;
			c1 = Math.random()*100+154;
		}
		var c2 = (brightness-frameCount)*4;
		if (cc < .33)
		{
			var color = get_rgb(Math.random()*5,c0+c2,c1+c2);
		}
		else if (cc < .66)
		{
			var color = get_rgb(c0+c2,c1+c2,Math.random()*5);
		}
		else
		{
			var color = get_rgb(c0+c2,Math.random()*5,c1+c2);
		}
		ctx.fillStyle = color
	}
	ctx.beginPath();
	ctx.rect(0,0,canvas.width,canvas.height);
	ctx.fill(); 
	drawTarget = ctx2;
	spriteArray[2].drawSprite(0,0,0);
	drawTarget.globalCompositeOperation = "source-atop";
	drawTarget.drawImage(lightBand,(frameCount % 400-40)*15,(frameCount % 400-40)*30)
	drawTarget.globalCompositeOperation = "none";
	
	var i;
	for (i = 0; i < objectArray.length; i ++) {
		objectArray[i].drawSelf();
	}
	drawTarget = ctx;
	spriteArray[3].drawSprite(404,615,0);
	spriteArray[9].drawSprite(423,528,0);
	if ((snd.currentTime > 29.5 && snd.currentTime < 33.5))
	{
		spriteArray[8].drawSprite(210,459,frameCount);
	}
	else
	{
		spriteArray[6].drawSprite(210,459,0);
		spriteArray[5].drawSprite(210+Math.sin(frameCount*.8)*2+1,459+Math.sin(frameCount*.8)*2+1,0);
	}
	spriteArray[7].drawSprite(857,527,frameCount/10);
	ctx.globalAlpha=0.2;
	ctx.beginPath();
	ctx.rect(0,0,canvas.width,canvas.height);
	ctx.fill(); 
	ctx.globalAlpha=1;
	
	spriteArray[4].drawSprite(399,38,0);
	spriteArray[0].drawSprite(0,0,frameCount);
	drawTarget.drawImage(buffer, 159,200 + Math.min(Math.max(Math.sin(frameCount/10)*20,-15),15));
	spriteArray[1].drawSprite(0,0,0);
	ctx.fillStyle = "#aa00ff";
	//ctx.fillText(color, 100, 100);
	//ctx.fillText(snd.currentTime, 100, 115);
}
function get_random_value() {
    var letters = '0123456789ABCDEF'.split('');
    var color = '#';
	value = "0";
	value += letters[Math.round(Math.random() * Math.random() * 15)];
	//value += value;
    for (var i = 0; i < 3; i++ ) {
        color += value;
    }
    return color;
}
function decimalToHex(d, padding) {
    var hex = Number(d).toString(16);
    padding = typeof (padding) === "undefined" || padding === null ? padding = 2 : padding;

    while (hex.length < padding) {
        hex = "0" + hex;
    }
    return hex;
}
function get_rgb(red,green,blue) {
    //var letters = '0123456789ABCDEF'.split('');
	var r = decimalToHex(Math.min(Math.floor(red),255),2);
	var g = decimalToHex(Math.min(Math.floor(green),255),2);
	var b = decimalToHex(Math.min(Math.floor(blue),255),2);
    var color = '#' + r + g + b;
    return color;
}
var renderToCanvas = function (width, height, renderFunction) {
    var buffer = document.createElement('canvas');
    buffer.width = width;
    buffer.height = height;
    renderFunction(buffer.getContext('2d'));
    return buffer;
};
function gameLoop() {
	"use strict";
	var i;
	for (i = 0; i < objectArray.length; i ++) {
		objectArray[i].step();
	}
	if (frameCount == 120)
	{
		snd.play();
		//snd.currentTime = 35;
	}
	//objectArray[0].imageIndex += 0.1;
	if (frameCount > 120)
	{
		drawStuff();
	}
	frameCount ++;
}
function gridObject(x,y,sprite) {
	this.x = x;
	this.y = y;
	this.sprite = sprite;
	this.imageIndex = 0;
	this.imageSpeed = 0.1;
	this.setSprite = function (sprite) {
		this.sprite = sprite;
	};
	this.drawSelf = function () {
		if (sprite != -1)
		{
			this.sprite.drawSprite(this.x,this.y,this.imageIndex);
		}
	};
	this.step = function() {
		this.imageIndex += this.imageSpeed;
	};
}
function sprite(originX,originY) {
	this.originX = originX;
	this.originY = originY;
	this.imageArray = [];
	this.addImage = function(image) {
		//uses the image object, not the image source
		this.imageArray[this.imageArray.length] = image;
	};
	this.drawSprite = function(x,y,subimage)
	{
		var image = this.imageArray[Math.floor(subimage) % this.imageArray.length];
		drawTarget.drawImage(image, x - this.originX, y - this.originY);
	};
}
function imagesInit() {
	var gameOver = new Image();
	gameOver.src = 'sprites/gameOver.png';
	var video0 = new Image();
	video0.src = 'sprites/video0.png';
	var video1 = new Image();
	video1.src = 'sprites/video1.png';
	var video2 = new Image();
	video2.src = 'sprites/video2.png';
	var vignette = new Image();
	vignette.src = 'sprites/vignette.png';
	var spotLight0 = new Image();
	spotLight0.src = 'sprites/spotLight0.png';
	var spotLight1 = new Image();
	spotLight1.src = 'sprites/spotLight1.png';
	var miyaHead = new Image();
	miyaHead.src = 'sprites/miyaHead.png';
	var miyaBody = new Image();
	miyaBody.src = 'sprites/miyaBody.png';
	var boomBox0 = new Image();
	boomBox0.src = 'sprites/boomBox0.png';
	var boomBox1 = new Image();
	boomBox1.src = 'sprites/boomBox1.png';
	var miyaYell0 = new Image();
	miyaYell0.src = 'sprites/miyaYell0.png';
	var miyaYell1 = new Image();
	miyaYell1.src = 'sprites/miyaYell1.png';
	var dead = new Image();
	dead.src = 'sprites/deadPeople.png';
	var a = [];
	a[0] = new sprite(0,0);
	a[0].addImage(video0);
	a[0].addImage(video1);
	a[0].addImage(video2);
	a[1] = new sprite(0,0);
	a[1].addImage(vignette);
	a[2] = new sprite(0,0);
	a[2].addImage(gameOver);
	a[3] = new sprite(0,0);
	a[3].addImage(spotLight0);
	a[4] = new sprite(0,0);
	a[4].addImage(spotLight1);
	a[5] = new sprite(0,0);
	a[5].addImage(miyaHead);
	a[6] = new sprite(0,0);
	a[6].addImage(miyaBody);
	a[7] = new sprite(0,0);
	a[7].addImage(boomBox0);
	a[7].addImage(boomBox1);
	a[8] = new sprite(0,0);
	a[8].addImage(miyaYell0);
	a[8].addImage(miyaYell1);
	a[9] = new sprite(0,0);
	a[9].addImage(dead);
	return a;
}
function gridSnap(value,intervals) {
	return Math.floor(value/intervals) * intervals;
}

var canvas = document.getElementById('canvas');
var ctx = canvas.getContext('2d');
/*var canvas2 = document.getElementById('layer');
canvas2.width = 882;
canvas2.height = 163*/

var snd = new Audio("Savant - Kali 47.mp3"); 


var gridSize = 16;


var spriteArray = imagesInit();
var gameDelay = 1000/20;
var x0 = 0;
var y0 = 0;
var x1 = 0;
var y1 = 0;
var rad;
var d=new Date();
var prevTime = d.getTime();
var objectArray = [];
var frameCount = 0;
var cc = 0;
var c0 = 0;
var c1 = 0;
var brightness = 0;
var buffer = document.createElement('canvas');
buffer.width = 882;
buffer.height = 163;
var ctx2 = buffer.getContext('2d');
var drawTarget = ctx2;

drawTarget = ctx;
var lightBand = new Image();
lightBand.src = 'sprites/lightBand.png';
//objectArray[objectArray.length] = new gridObject(0,0,spriteArray[0]);
//window.addEventListener('resize', resizeCanvas, false);
var timer = setInterval(function() {
"use strict";
gameLoop();
},gameDelay);