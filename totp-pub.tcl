#!/usr/bin/env tclsh
#!/usr/bin/wapptclsh

# MSN Teams
# set SECRET ""

# MSN xtest 
# set SECRET ""

#IDME
#set SECRET ""

# Github
# gihthub_p

# MS NinjaE

# LogGov

set COLLECTIONS [dict create \
LOGNGOV "" \
IDME 	 "" \
MSNXTEST ""	\
]

source /usr/local/lib/tcltk/wapp/wapp.tcl
source /usr/local/lib/tcltk/mtotp.tcl
package require base32

if {[catch {package require wapp}]} {
  source [file dir [file dir [info script]]]/wapp.tcl
}

proc wapp-default {} {
  # Local variable for CLI dividing
  set divider "------- + ---------- + --------"

  # Get outerscope variables to be recognized in this scope.
  global SECRET
  global COLLECTIONS

  # Define helper fucnction that produces list of time for each epoch that gets printed to HTML and CLI.
  proc pubtoken {when} {
        list [t totp [expr {$when-30}]] [t totp $when] [t totp [expr {$when+30}]]
    }

  wapp-content-security-policy {script-src 'self' 'unsafe-inline'}

  wapp-trim {
    <style>
        html { background: black; }
        #pass { color: gray; font-size: 12pt; float: left; margin: 10px ; }
        #mid  { color: green; font-size: 18pt; float: left; margin: 10px; font-weight: bolder; outline-style: dotted; padding: 5px ; }
        #nex  { color: gray; font-size: 12pt; float: left; margin: 10px ; }
    </style>
  }

  wapp-trim {
    <h1>Angehend Auftraege Auf 7007</h1>

  }


# Iterate the global collection for each entry and write to HTML
dict for {site code} $COLLECTIONS {

    totp::totp create t [base32::decode $code]

    set epocas [pubtoken [clock seconds]]
    puts "[string tolower $site] => $epocas"
    lassign $epocas pass mid nex

    wapp-subst {

	<section name="Ziele">
          <h3>%html($site)</h3>    <!--- Move this line into the div for better styling --->
        <div>
          <p>
            <p id='pass'>%html($pass)</p>
            <p id='mid'>%html($mid)</p>
            <p id='nex'>%html($nex)</p>
          </p>
        </div>
	</section>
    }

    ::t destroy
}

# CLI visual linebreak for console view
puts $divider

# HTML Footer with countdown timer
wapp-trim {
    <hr style='clear: both; '></hr>

    <p style="color:blue" id='updateIn'>--</p>
    <script src='%url([wapp-param SCRIPT_NAME]/script.js)'></script>
    <script> setInterval(timerTick, 1000); </script>
  }


}

# This should write to a logfile all requests. Extend it later to checksize and rotate.
proc wapp-before-reply-hook {} {
  set now [clock format [clock seconds] -format "%a %d-%b-%Y %T"]
  set msg "------------ New Request @ $now ---------\n"
  append msg "Recieved Request at [wapp-param .header] \n
   \t\t with content:  [wapp-param CONTENT] \n
   \t\t from remote:   [wapp-param REMOTE_ADDR] \n
   \t\t with U-Agent:   [wapp-param HTTP_USER_AGENT] \n
   \t\t [wapp-param .reply-code] code and reply sent [wapp-param .reply]\n\n"


  set bname [wapp-param SCRIPT_FILENAME]
  set logfile "/var/log/"
  append logfile [file root [file tail $bname]]-log.txt
  set out [open $logfile a]
  puts $out $msg
  close $out
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
