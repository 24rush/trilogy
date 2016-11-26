using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.ActivityMonitor as Act;
using Toybox.Time.Gregorian as Calendar;

class trilogyView extends Ui.WatchFace {

	var scrW = 0, scrH = 0;
	var batBarH = 32;

	var disabledColor = Gfx.COLOR_DK_GRAY;
	var accentColor = Gfx.COLOR_ORANGE;
	var nonAccentColor = Gfx.COLOR_WHITE;
	
	var moireFont, moireFontSmall;
	
	function refresh() {
		var userAccentColor = Application.getApp().getProperty("accentColor");	
        if (userAccentColor != 0) {
        	accentColor = userAccentColor;
        }
                
        System.println(userAccentColor);
	}
	
    function initialize() {
        WatchFace.initialize();
                
		var userAccentColor = Application.getApp().getProperty("accentColor");	
        if (userAccentColor != 0) {
        	accentColor = userAccentColor;
        }
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        scrW = dc.getWidth();
        scrH = dc.getHeight();
        
        moireFont = Ui.loadResource(Rez.Fonts.font_moire);
        moireFontSmall = Ui.loadResource(Rez.Fonts.font_moire_small);		        
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

	function getCirclePos(angle) {
		var theta = angle * 3.1416 / 180;
		var cx = scrW / 2, cy = scrH / 2, r = scrW / 2;
		 
		return [cx + r * Math.cos(theta),(-cy + r * Math.sin(theta)).abs()];
	}
	
	function getPointData(angle) {
		var sp = getCirclePos(angle);
		
		var ep, beta;
		
		if (angle <= 90) {
			beta = 90- angle +90; 
		} else if (angle <= 180) {
			beta = 180 - angle;
		} else if (angle <= 270) {
			beta = 270 - angle + 270;
		} else {
			beta = angle;
		}
		
		ep = getCirclePos(beta);
		
		return [sp[0], sp[1], (ep[0] - sp[0]).abs()];
	}
	
    // Receives value between [0, 1]
    function drawBar(dc, angle, value, text, textLabel) {
    	if (value > 1) {
    	    value = 1;
    	}
    	    	                      	
        var correct = 0;
        if (angle < 180) {
        	correct = -batBarH;
        }
         	
		var stP = getPointData(angle);
                                     
        var color = Gfx.COLOR_LT_GRAY;
        
        dc.setColor(disabledColor, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(stP[0], stP[1] +correct, stP[2] +2, batBarH);
        
        dc.setColor(color, color);               
        dc.fillRectangle(stP[0], stP[1] +correct, value * stP[2], batBarH);
        
        var overlayH = 18;
        var offset = (batBarH - overlayH) / 2;
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);   
        dc.fillRectangle(stP[0], stP[1] +7 +correct, stP[2] +2, overlayH);                                         	
                   
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 -5, stP[1] +4 +correct, moireFontSmall, text, Gfx.TEXT_JUSTIFY_RIGHT);
                
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 +5, stP[1] +4 +correct, moireFontSmall, textLabel, Gfx.TEXT_JUSTIFY_LEFT);              
    }
     
    //! Update the view
    function onUpdate(dc) {             
        View.onUpdate(dc);                                    
               
        if (Sys.getDeviceSettings().notificationCount > 0) {
        	dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);
        	dc.fillCircle(scrW/2, scrH/2, scrW/2);
        	
        	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        	dc.fillCircle(scrW/2, scrH/2, scrW/2 -3);
        }
        
		// Steps Goal  		
		drawBar(dc, 205, Act.getInfo().steps * 1.0 / Act.getInfo().stepGoal, "STEPS", Act.getInfo().steps.toString());
		// Move
		//drawBar(dc, 210, (5 - Act.getInfo().moveBarLevel) * 1.0 / 5, "MOVE IN", (15 * Act.getInfo().moveBarLevel).toString() +" min");				    			                         
        // Battery level
		drawBar(dc, 227, Sys.getSystemStats().battery / 100, "BATT", Sys.getSystemStats().battery.toNumber().toString() + "%");
		
		var clockTime = Sys.getClockTime();                               
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_MEDIUM);

        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);          
        
        var startY = 15;
        
        // Date                    
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(scrW/2, startY, Gfx.FONT_SMALL, dateStr.toUpper(), Gfx.TEXT_JUSTIFY_CENTER);
        
        var min = clockTime.min.toString();
        if (clockTime.min < 10) {
        	min = "0" + min;
        }
        
        var hcorrect = 2;
        var hour = clockTime.hour.toString();
        if (clockTime.hour < 10) {
        	hour = "0" + hour;        	
        } else if (clockTime.hour < 20) {
        	hcorrect = 8;
        }
                 
        startY += 20;
        
        // Hour				
		dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);  
        dc.drawText(scrW/2 , startY+1, moireFont, hour.substring(1, 2), Gfx.TEXT_JUSTIFY_RIGHT);
        
		dc.setColor(nonAccentColor, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 +1, startY, moireFont, hour.substring(1, 2), Gfx.TEXT_JUSTIFY_RIGHT);
                
        var dl = 39; // Font letter width  
        
        dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);  
        dc.drawText(scrW/2 +hcorrect -dl, startY+1, moireFont, hour.substring(0, 1), Gfx.TEXT_JUSTIFY_RIGHT);
        
		dc.setColor(nonAccentColor, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 +hcorrect -dl +1, startY, moireFont, hour.substring(0, 1), Gfx.TEXT_JUSTIFY_RIGHT);
                
       // Minute
       	dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
       	dc.drawText(scrW/2 +1 + dl, startY+1, moireFont, min.substring(1, 2), Gfx.TEXT_JUSTIFY_LEFT);
       	
        dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 +1  + dl, startY, moireFont, min.substring(1, 2), Gfx.TEXT_JUSTIFY_LEFT);		
        
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
       	dc.drawText(scrW/2 +1, startY+1, moireFont, min.substring(0, 1), Gfx.TEXT_JUSTIFY_LEFT);
       	
        dc.setColor(accentColor, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 +1, startY, moireFont, min.substring(0, 1), Gfx.TEXT_JUSTIFY_LEFT);				
       
        var cal = Act.getInfo().calories;
        
        startY += 90;
        // Calories
		var calDistColor = Gfx.COLOR_LT_GRAY;
		dc.setColor(calDistColor, Gfx.COLOR_TRANSPARENT);    
        dc.drawText(scrW/2 -5, startY, moireFontSmall,  cal.toString() + " cal", Gfx.TEXT_JUSTIFY_RIGHT);
        
        // Distance
		var distance = Act.getInfo().distance;
		var stepsLabel = "";
        if (distance > 100000) {    
        	stepsLabel = ((distance * 1.0 / 100000).format("%04.2f")).toString() + " K";
        } else {
        	stepsLabel = ((distance * 1.0 / 100).format("%04.2f")).toString() + " M";
      	}
      	
      	dc.setColor(calDistColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(scrW/2 +5, startY, moireFontSmall, stepsLabel, Gfx.TEXT_JUSTIFY_LEFT);        
    }   

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {    
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
