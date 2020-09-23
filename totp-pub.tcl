#!/usr/bin/wapptclsh
# Actually can run by using just tclsh interpreter due to source calls of wapp below

set SECRET ""

source /usr/local/lib/tcltk/wapp/wapp.tcl
source /usr/local/lib/tcltk/mtotp.tcl
package require base32

if {[catch {package require wapp}]} {
  source [file dir [file dir [info script]]]/wapp.tcl
}

proc wapp-default {} {
  global SECRET
  wapp-content-security-policy {script-src 'self' 'unsafe-inline'}

  wapp-trim {
    <h1>SHATEST</h1>
  }

  global SECRET
  totp::totp create t [base32::decode $SECRET]

  proc pubtoken {when} {
        list [t totp [expr {$when-30}]] [t totp $when] [t totp [expr {$when+30}]]
    }

    set val [pubtoken [clock seconds]]
    puts $val
    lassign $val pass mid nex
    
  wapp-trim {
    <h3>Current Middle:</h3>
    <p style='color: gray; font-size: 12pt; float: left; margin: 10px ;'>%html($pass)</p>
    <p style='color: green; font-size: 18pt; float: left; margin: 10px; font-weight: bolder; outline-style: dotted; padding: 5px ;'>%html($mid)</p>
    <p style='color: gray; font-size: 12pt; float: left; margin: 10px ;'>%html($nex)</p>
    <hr style='clear: both; '></hr>
    <p style="color:blue" id='updateIn'>--</p>
    <script src='%url([wapp-param SCRIPT_NAME]/script.js)'></script>
    <script> setInterval(timerTick, 1000); </script>
  }

  ::t destroy
}


# This is the javascript that takes refreshes page every 30 seconds
proc wapp-page-script.js {} {
  wapp-mimetype text/javascript
  wapp-cache-control max-age=0
  wapp-trim {

      setInterval(timerTick, 1500);

      var timerTick = function() {
      var epoch = Math.round(new Date().getTime() / 1000.0);
      var countDown = 30 - (epoch % 30);
         if (epoch % 30 === 0) {
             location.reload(true);  //refresh page
         }

        document.getElementById('updateIn').textContent = countDown;
        };
  }
}

lappend $::argv
wapp-start $::argv
