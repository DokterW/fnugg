#!/bin/bash
# fnugg v0.14
# Made by Dr. Waldijk
# A simple weather script that fetches weather data from darksky.net.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
FNUNAM="fnugg"
FNUVER="0.15"
FNUDIR="$HOME/.dokter/fnugg"
# Your API key for darksky.net
#FNUKEY=""
if [ ! -e $FNUDIR/fnukey ]; then
    while :; do
        clear
        echo "Do you have an API key?"
        read -p "(y/n): " -s -n1 FNUKEY
        case "$FNUKEY" in
            [yY])
                clear
                read -p "Enter your Dark Sky API key: " FNUKEY
                echo "$FNUKEY" > $FNUDIR/fnukey
                clear
                break
            ;;
            [nN])
                clear
                exit
            ;;
        esac
    done
    clear
else
    FNUKEY=$(cat $FNUDIR/fnukey)
fi
# Goelocations sample
if [ ! -e $FNUDIR/fnulist ]; then
    wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/$FNUNAM/master/fnulist -P $FNUDIR/
    FNULST=$(cat $FNUDIR/fnulist | tail -n +2)
else
    FNULST=$(cat $FNUDIR/fnulist | tail -n +2)
fi
# Refresh (in seconds)
FNUREF="600"
# Location
#FNULOC="Oslo"
# Latitude
#FNULAT="59.9115565"
# Longitude
#FNULON="10.7333091"
# Language
FNULAN="en"
# Units
FNUNIT="si"
# Install dependencies --------------------------------------------------------------
if [ ! -e /usr/bin/curl ] && [ ! -e /usr/bin/jq ] && [ ! -e /usr/bin/fmt ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install curl jq
    else
        echo "You need to install curl, jq and fmt."
    fi
elif [ ! -e /usr/bin/curl ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install curl
    else
        echo "You need to install curl."
    fi
elif [ ! -e /usr/bin/jq ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install jq
    else
        echo "You need to install jq."
    fi
elif [ ! -e /usr/bin/fmt ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install fmt
    else
        echo "You need to install fmt."
    fi
fi
# -----------------------------------------------------------------------------------
while :; do
    clear
    FNUCNT=$(echo "$FNULST" | wc -l)
    echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
    echo ""
    echo "$FNULST" | cut -d , -f 1 | nl -nrz -w2 -s- | sed 's/-/. /g'
    echo "QQ. Quit"
    echo ""
    read -p "Enter option: " -s -n2 FNUSNO
    FNULIN=$(echo "$FNUSNO" | sed 's/^0*//')
    if [ "$FNULIN" -gt "$FNUCNT" ] || [ "$FNULIN" -lt "0" ]; then
        clear
        echo "Butterfingers!"
        sleep 3s
    else
        case $FNUSNO in
            [0-9][0-9])
                # Location
                FNULOC1=$(echo "$FNULST" | sed -n "$FNULIN p" | cut -d , -f 1)
                FNULOC3=$(echo "$FNULST" | sed -n "$FNULIN p" | cut -d , -f 3)
                # Latitude
                FNULAT=$(echo "$FNULST" | sed -n "$FNULIN p" | cut -d , -f 4)
                # Longitude
                FNULON=$(echo "$FNULST" | sed -n "$FNULIN p" | cut -d , -f 5)
            ;;
            qq|QQ)
                clear
                break
            ;;
        esac
        while :; do
            FNUAPI=$(curl -s "https://api.darksky.net/forecast/$FNUKEY/$FNULAT,$FNULON?lang=$FNULAN&exclude=minutely,hourly,alerts,flags&units=$FNUNIT")
            FNUTIZ=$(echo "$FNUAPI" | jq -r '.timezone')
            FNUCOL=$(tput cols)
            # Current
            FNUTMP=$(echo "$FNUAPI" | jq -r '.currently.temperature')
            FNUTFL=$(echo "$FNUAPI" | jq -r '.currently.apparentTemperature')
            FNUWND=$(echo "$FNUAPI" | jq -r '.currently.windSpeed')
            FNUSUM=$(echo "$FNUAPI" | jq -r '.currently.summary')
            # Today
            FNUTMPW1K0=$(echo "$FNUAPI" | jq -r '.daily.data[0].temperatureMax')
            FNUTMPW2K0=$(echo "$FNUAPI" | jq -r '.daily.data[0].temperatureMin')
            FNUPRPTOD=$(echo "$FNUAPI" | jq -r '.daily.data[0].precipProbability')
            FNUPRPTOD=$(echo "$FNUPRPTOD*100" | bc | sed 's/\.00//')
            FNUPRTTOD=$(echo "$FNUAPI" | jq -r '.daily.data[0].precipType')
            if [ "$FNUPRTTOD" = "null" ]; then
                FNUPRTTOD=""
            else
                FNUPRTTOD=$(echo "chance of $FNUPRTTOD")
            fi
            FNUSNRTOD=$(echo "$FNUAPI" | jq -r '.daily.data[0].sunriseTime')
            FNUSNRTOD=$(TZ=$FNUTIZ date --date="@$FNUSNRTOD" +%H:%M)
            FNUSNSTOD=$(echo "$FNUAPI" | jq -r '.daily.data[0].sunsetTime')
            FNUSNSTOD=$(TZ=$FNUTIZ date --date="@$FNUSNSTOD" +%H:%M)
            FNUSUMTOD=$(echo "$FNUAPI" | jq -r '.daily.data[0].summary')
            # Tomorrow
            FNUTMPW1K1=$(echo "$FNUAPI" | jq -r '.daily.data[1].temperatureMax')
            FNUTMPW2K1=$(echo "$FNUAPI" | jq -r '.daily.data[1].temperatureMin')
            FNUPRPTOM=$(echo "$FNUAPI" | jq -r '.daily.data[1].precipProbability')
            FNUPRPTOM=$(echo "$FNUPRPTOM*100" | bc | sed 's/\.00//')
            FNUPRTTOM=$(echo "$FNUAPI" | jq -r '.daily.data[1].precipType')
            if [ "$FNUPRTTOM" = "null" ]; then
                FNUPRTTOM=""
            else
                FNUPRTTOM=$(echo "chance of $FNUPRTTOM")
            fi
            FNUSNRTOM=$(echo "$FNUAPI" | jq -r '.daily.data[1].sunriseTime')
            FNUSNRTOM=$(TZ=$FNUTIZ date --date="@$FNUSNRTOM" +%H:%M)
            FNUSNSTOM=$(echo "$FNUAPI" | jq -r '.daily.data[1].sunsetTime')
            FNUSNSTOM=$(TZ=$FNUTIZ date --date="@$FNUSNSTOM" +%H:%M)
            FNUSUMWEK1=$(echo "$FNUAPI" | jq -r '.daily.data[1].summary')
            clear
            echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
            echo ""
            echo ":: Current ::"
            echo "     Location: $FNULOC1, $FNULOC3"
            echo "  Temperature: $FNUTMP°C"
            echo "   Feels like: $FNUTFL°C"
            echo "         Wind: $FNUWND m/s"
            echo -n "      Summary:"
            echo "               $FNUSUM" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
            echo ""
            echo ":: Today ::"
            echo "  Temperature: $FNUTMPW1K0°C ($FNUTMPW2K0°C)"
            echo "Precipitation: $FNUPRPTOD% $FNUPRTTOD"
            echo "      Sunrise: $FNUSNRTOD"
            echo "       Sunset: $FNUSNSTOD"
            echo -n "      Summary:"
            echo "               $FNUSUMTOD" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
            echo ""
            echo ":: Tomorrow ::"
            echo "  Temperature: $FNUTMPW1K1°C ($FNUTMPW2K1°C)"
            echo "Precipitation: $FNUPRPTOM% $FNUPRTTOM"
            echo "      Sunrise: $FNUSNRTOM"
            echo "       Sunset: $FNUSNSTOM"
            echo -n "      Summary:"
            echo "               $FNUSUMWEK1" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
            echo ""
            echo "(Q)uit |    5-day   | (Any key)"
            read -t $FNUREF -s -n1 -p "       | (f)orecast | to refresh: " FNUQUT
            case "$FNUQUT" in
                [fF])
                    FNUCANT=1
                    until [ "$FNUCANT" -eq "6" ]; do
                        FNUCANT=$(expr $FNUCANT + 1)
                        FNUDAYWEK[$FNUCANT]=$(echo "$FNUAPI" | jq -r ".daily.data[$FNUCANT].time")
                        FNUDAYWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUDAYWEK[$FNUCANT]}" +%A)
                        FNUDAYWEK[$FNUCANT]=$(echo "${FNUDAYWEK[$FNUCANT]^}")
                        FNUTMPW1K[$FNUCANT]=$(echo "$FNUAPI" | jq -r ".daily.data[$FNUCANT].temperatureMax")
                        FNUTMPW2K[$FNUCANT]=$(echo "$FNUAPI" | jq -r ".daily.data[$FNUCANT].temperatureMin")
                        FNUSUMWEK[$FNUCANT]=$(echo "$FNUAPI" | jq -r ".daily.data[$FNUCANT].summary")
                    done
                    FNUCANT=1
                    clear
                    echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
                    echo ""
                    echo "Location: $FNULOC1, $FNULOC3"
                    echo ""
                    until [ "$FNUCANT" -eq "6" ]; do
                        FNUCANT=$(expr $FNUCANT + 1)
                        echo ":: ${FNUDAYWEK[$FNUCANT]} ::"
                        echo "  Temperature: ${FNUTMPW1K[$FNUCANT]}°C (${FNUTMPW2K[$FNUCANT]}°C)"
                        echo -n "      Summary:"
                        echo "               ${FNUSUMWEK[$FNUCANT]}" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
                        echo ""
                    done
                    read -p "Press any key to continue... " -n1 -s
                ;;
                [qQ])
                    echo ""
                    break
                ;;
                *)
                    continue
                ;;
            esac
        done
    fi
done
