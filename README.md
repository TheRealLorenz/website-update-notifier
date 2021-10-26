# Website update notifier

Simple wrapper script for wkhtmltoimage. It can tell when there's been an update to the website, checking the entire page or even a specific section.

Once it notices a change occurred, it executes a script called 'send-notify.sh', in the same folder as the script.

The script also has a buffer system so that only difference that occurs at least two times are considered effective, thus reducing the amount of errors cause by internet connection.

## How to use it

Clone and prepare the repo:

    git clone https://github.com/TheRealLorenz/website-update-notifier
    cd website-update-notifier
    chmod +x get-website.sh send-notify.sh

At this point there are 3 methods for passing the url and the area to crop the screenshot

### Execute the setup [WIP]

Pass the flag '--setup' to the 'get-website.sh' script:

    ./get-website.sh --setup

This will create a 'get-website.conf' in the current directory containing all the required metadatas.

### Pass the arguments via environmental variables [WIP]

Use the environmental variables for passing arguments to the script:

    URL="myurl.com" WIDTH=1024 HEIGHT=1000 CROP_X=0 CROP_Y=0 CROP_WIDTH=1024 CROP_HEIGHT=1000 ./get-website.sh

### Hardcode the variables into the script

Just open the file with your preferred editor and edit all the variables accordingly.

## Using the script along with systemd

You can execute this script periodically with the help of systemd timers. Here you can find an example that executes 'get-website.sh' every 15 mins.

!!! Path

#### Example systemd unit timer

    [Unit]
    Description=Exec get website every 15 min
    
    [Timer]
    OnBootSec=15min
    OnUnitActiveSec=15min
    
    [Install]
    WantedBy=default.target

### Example systemd unit service

    [Unit]
    Description=Get website service
    
    [Service]
    Type=oneshot
    ExecStart=/path/to/get-website.sh
    
    [Install]
    WantedBy=default.target   WantedBy=timers.target
