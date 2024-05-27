var side = new Array(3);
side[0] = new Array(100);
side[1] = new Array(20);
side[2] = new Array(20);
for (var j = 0; j < 3; j++)
{
	for (var i = 0; i < 100; i++)
	{
		side[j][i] = 0;
	}
}

function drawStuff() {
	"use strict";	 
	
	ctx.fillStyle = 'white';
	ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);
	var speed = 750;
	var lineCount = 10;
	var minRadius = 50;
	for (var i = 0; i < lineCount; i++)
	{
		ctx.beginPath();
		var b = (((frameCount+i*speed/lineCount) % speed)-speed/2)/(speed/2)
		var a = minRadius/b;
		if (b != 0)
		{
			ctx.arc(centerX-a-b*width, centerY, Math.abs(a), 2*Math.PI, 0);
		}
		else
		{
			ctx.moveTo(centerX,0);
			ctx.lineTo(centerX,canvas.height);
		}
		ctx.stroke();
		
	}
	var lineCount = 10
	
	for (var i = 0; i < lineCount; i++)
	{
		var b = (((frameCount+i*speed/lineCount) % speed)-speed/2)/(speed/2)
		var c = (100/b)-100*Math.sign(b);
		var d = findTangentDist(centerX,centerY-c,centerX+width+minRadius,centerY,minRadius);
		ctx.beginPath();
		if (b != 0)
		{
			ctx.arc(centerX, centerY-c,d, 2*Math.PI, 0);
		}
		else
		{
			ctx.moveTo(0,centerY);
			ctx.lineTo(canvas.width,centerY);
		}
		ctx.stroke();
	}
	for (var j = 0; j < 3; j++)
	{
		ctx.beginPath();
		var prevX;
		var prevY;
		var rep = side[j].length;
		for (var i = 0; i < rep; i++)
		{
			if (j == 0)
			{
				if (i < 50)
				{
					var e0 = Math.sin((i/100) * 2* Math.PI)*10;
					var e1 = Math.cos((i/100) * 2*Math.PI)*10;
				}
				else
				{
					var e0 = Math.sin((50/100) * 2 * Math.PI)*10 + -Math.sin(((i)/50) * Math.PI)*10;
					var e1 = Math.cos((50/100) * 2 * Math.PI)*10 + -Math.cos(((i)/50) * Math.PI)*10-10;
				}
			}
			else if (j == 1)
			{
				var e0 = -10 - i * 2;
				var e1 = 2;
				if (i > 10)
				{
					break;
				}
			}
			else if (j == 2)
			{
				var e0 = -10 - i * 2;
				var e1 = -20;
				if (i > 10)
				{
					break;
				}
			}
			var t0 = (((frameCount+875+e0) % speed)-speed/2)/(speed/2)
			var t1 = (((frameCount+420+e1) % speed)-speed/2)/(speed/2)
			var t2 = ((((frameCount-1)+875+e0) % speed)-speed/2)/(speed/2)
			var t3 = ((((frameCount-1)+420+e1) % speed)-speed/2)/(speed/2)
			if (t0 != 0 && t1 != 0)
			{
				if ((Math.abs(t0-t2) < 1 && Math.sign(t0) != Math.sign(t2)) || (Math.abs(t1-t3) < 1 && Math.sign(t1) != Math.sign(t3)))
				{
					side[j][i] = 1 - side[j][i];
				}
				//ctx.lineWidth=10;
				var a = minRadius/t0;
				var r0 = Math.abs(a);
				var x0 = centerX-a-t0*width;
				var y0 = centerY;
				
				var b = (100/t1)-100*Math.sign(t1);
				var x1 = centerX;
				var y1 = centerY-b;
				var r1 = findTangentDist(x1,y1,centerX+width+minRadius,centerY,minRadius);
				var p = intersection(x0,y0,r0,x1,y1,r1);
				ctx.fillStyle = "black";
				ctx.font = "bold 16px Arial";
				/*if (j == 0 && i == 0)
				{
					ctx.fillText(t0,100,200);
					ctx.fillText(t1,100,220);
				}*/
				var aa = (side[j][i] == 0);
				//if (j == 0)
				{
					if (aa)
					{
						var bb = Math.sqrt(Math.pow(p.x0 - prevX,2) + Math.pow(p.y0 - prevY,2));
					}
					else
					{
						var bb = Math.sqrt(Math.pow(p.x1 - prevX,2) + Math.pow(p.y1 - prevY,2));
					}
					
					if (i > 0 && 20 > bb)
					{
						if (aa)
						{
							ctx.lineTo(p.x0, p.y0);
							prevX = p.x0;
							prevY = p.y0;
						}
						else
						{
							ctx.lineTo(p.x1, p.y1);
							prevX = p.x1;
							prevY = p.y1;
						}
					}
					else
					{
						if (aa)
						{
							ctx.moveTo(p.x0, p.y0);
							prevX = p.x0;
							prevY = p.y0;
						}
						else
						{
							ctx.moveTo(p.x1, p.y1);
							prevX = p.x1;
							prevY = p.y1;
						}
					}
				}
				/*else
				{
					if (i > 0)
					{
						ctx.lineTo(p.x1, p.y1);
					}
					else
					{
						ctx.moveTo(p.x1, p.y1);
					}
				}*/
				
			}
		}
		ctx.stroke();
	}
	ctx.lineWidth=1;
	ctx.fillStyle = 'white';
	ctx.beginPath();
	ctx.arc(centerX-minRadius-width, centerY, minRadius, 2*Math.PI, 0);
	ctx.fill();
	ctx.beginPath();
	ctx.arc(centerX-minRadius-width, centerY, minRadius, 2*Math.PI, 0);
	ctx.stroke();
	ctx.beginPath();
	ctx.arc(centerX+minRadius+width, centerY, minRadius, 2*Math.PI, 0);
	ctx.fill();
	ctx.beginPath();
	ctx.arc(centerX+minRadius+width, centerY, minRadius, 2*Math.PI, 0);
	ctx.stroke();
}
function resizeCanvas() {
	"use strict";
	canvas.width = window.innerWidth;
	canvas.height = window.innerHeight;
	centerX = canvas.width/2;
	centerY = canvas.height/2;
	drawStuff(); 
}
function findTangentDist(x0,y0,x1,y1,r)
{
	var cx = x1;
	var cy = y1;
	var px = x0;
	var py = y0;
	var radius = r;
	// find tangents
	var dx = cx - px;
	var dy = cy - py;
	var dd = Math.sqrt(dx * dx + dy * dy);
	var a = Math.asin(radius / dd);
	var b = Math.atan2(dy, dx);

	var t = b - a
	
	var ta = { x:radius * Math.sin(t), y:radius * -Math.cos(t) };
	t = b + a
	var tb = { x:radius * -Math.sin(t), y:radius * Math.cos(t) };
	var dist = Math.sqrt(Math.pow(x1-x0 + ta.x,2) + Math.pow(y1-y0+ta.y,2));
	return dist;
}
function intersection(x0, y0, r0, x1, y1, r1) {
	var a, dx, dy, d, h, rx, ry;
	var x2, y2;

	/* dx and dy are the vertical and horizontal distances between
	 * the circle centers.
	 */
	dx = x1 - x0;
	dy = y1 - y0;

	/* Determine the straight-line distance between the centers. */
	d = Math.sqrt((dy*dy) + (dx*dx));

	/* Check for solvability. */
	if (d > (r0 + r1)) {
		/* no solution. circles do not intersect. */
		return false;
	}
	if (d < Math.abs(r0 - r1)) {
		/* no solution. one circle is contained in the other */
		return false;
	}

	/* 'point 2' is the point where the line through the circle
	 * intersection points crosses the line between the circle
	 * centers.  
	 */

	/* Determine the distance from point 0 to point 2. */
	a = ((r0*r0) - (r1*r1) + (d*d)) / (2.0 * d) ;

	/* Determine the coordinates of point 2. */
	x2 = x0 + (dx * a/d);
	y2 = y0 + (dy * a/d);

	/* Determine the distance from point 2 to either of the
	 * intersection points.
	 */
	h = Math.sqrt((r0*r0) - (a*a));

	/* Now determine the offsets of the intersection points from
	 * point 2.
	 */
	rx = -dy * (h/d);
	ry = dx * (h/d);

	/* Determine the absolute intersection points. */
	var xi = x2 + rx;
	var xi_prime = x2 - rx;
	var yi = y2 + ry;
	var yi_prime = y2 - ry;

	return {x0:xi, x1:xi_prime, y0:yi, y1:yi_prime};
}
function gameLoop() {
	"use strict";
	drawStuff();
	frameCount ++;
}
var canvas = document.getElementById('canvas');
var ctx = canvas.getContext('2d');
var width = 50;
var gameDelay = 1000/30;
var frameCount = 0;
var centerX = canvas.width/2;
var centerY = canvas.height/2;
resizeCanvas();

//window.addEventListener('resize', resizeCanvas, false);
var timer = setInterval(function() {
"use strict";
gameLoop();
},gameDelay);