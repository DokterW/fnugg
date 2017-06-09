#!/bin/bash
# fnugg v0.17
# Made by Dr. Waldijk
# A simple weather script that fetches weather data from darksky.net.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
FNUNAM="fnugg"
FNUVER="0.17"
FNUDIR="$HOME/.dokter/fnugg"
# Your API key for darksky.net
# FNUSKY=""
# Your API key for mapbox.com
# FNUMAP=""
if [ ! -e $FNUDIR/fnusky ]; then
    while :; do
        clear
        echo "Do you have a Darksky API key?"
        read -p "(y/n): " -s -n1 FNUKEY
        case "$FNUKEY" in
            [yY])
                clear
                read -p "Enter your Dark Sky API key: " FNUSKY
                echo "$FNUSKY" > $FNUDIR/fnusky
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
    FNUSKY=$(cat $FNUDIR/fnusky)
fi
if [ ! -e $FNUDIR/fnumap ]; then
    while :; do
        clear
        echo "Do you have a Mapbox API key?"
        read -p "(y/n): " -s -n1 FNUKEY
        case "$FNUKEY" in
            [yY])
                clear
                read -p "Enter your Dark Sky API key: " FNUMAP
                echo "$FNUMAP" > $FNUDIR/fnumap
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
    FNUMAP=$(cat $FNUDIR/fnumap)
fi
# Removing old files
if [ -e $FNUDIR/fnukey ]; then
    rm $FNUDIR/fnukey
fi
if [ -e $FNUDIR/fnulst ]; then
    rm $FNUDIR/fnulst
fi
# Refresh (in seconds)
FNUREF="600"
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
    while :; do
        if [ -n "$FNUSRC" ]; then
            break
        fi
        clear
        echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
        echo ""
        read -p "Search for city: " FNUSRC
        if [ "$FNUSRC" = "q" ] || [ "$FNUSRC" = "Q" ]; then
            clear
            exit
        fi
        if [ -z "$FNUSRC" ]; then
            clear
            echo "Butterfingers!"
            sleep 3s
        else
            break
        fi
    done
    FNUMAPAPI=$(curl -s "https://api.mapbox.com/geocoding/v5/mapbox.places/$FNUSRC.json?access_token=$FNUMAP&types=place")
    FNULST=$(echo "$FNUMAPAPI" | jq -r '.features[].place_name' | nl -w1 -s'. ')
    FNUCNT=$(echo "$FNULST" | wc -l)
    clear
    echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
    echo ""
    echo "$FNULST"
    echo "Q. Quit"
    echo ""
    read -p "Enter option: " -s -n1 FNUKEY
    if [ "$FNUKEY" = "q" ] || [ "$FNUKEY" = "Q" ]; then
        clear
        break
    fi
    FNUKEY=$(expr $FNUKEY - 1)
    if [ "$FNUKEY" -gt "$FNUCNT" ] || [ "$FNUKEY" -lt "0" ] || [ -z "$FNUKEY" ]; then
        clear
        echo "Butterfingers!"
        sleep 3s
    else
        case $FNUKEY in
            [0-9])
                # Location
                FNULOC=$(echo "$FNUMAPAPI" | jq -r ".features[$FNUKEY].place_name")
                # Latitude
                FNULAT=$(echo "$FNUMAPAPI" | jq -r ".features[$FNUKEY].geometry.coordinates[1]")
                # Longitude
                FNULON=$(echo "$FNUMAPAPI" | jq -r ".features[$FNUKEY].geometry.coordinates[0]")
            ;;
            [qQ])
                clear
                break
            ;;
        esac
        while :; do
            FNUSKYAPI=$(curl -s "https://api.darksky.net/forecast/$FNUSKY/$FNULAT,$FNULON?lang=$FNULAN&exclude=minutely,hourly,alerts,flags&units=$FNUNIT")
            FNUTIZ=$(echo "$FNUSKYAPI" | jq -r '.timezone')
            FNUCOL=$(tput cols)
            # Current
            FNUTMP=$(echo "$FNUSKYAPI" | jq -r '.currently.temperature')
            FNUTFL=$(echo "$FNUSKYAPI" | jq -r '.currently.apparentTemperature')
            FNUWND=$(echo "$FNUSKYAPI" | jq -r '.currently.windSpeed')
            FNUSUM=$(echo "$FNUSKYAPI" | jq -r '.currently.summary')
            # Today
            FNUTMPW1K0=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].temperatureMax')
            FNUTMPW2K0=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].temperatureMin')
            FNUPRPTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].precipProbability')
            FNUPRPTOD=$(echo "$FNUPRPTOD*100" | bc | sed 's/\.00//')
            FNUPRTTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].precipType')
            if [ "$FNUPRTTOD" = "null" ]; then
                FNUPRTTOD=""
            else
                FNUPRTTOD=$(echo "chance of $FNUPRTTOD")
            fi
            FNUSNRTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].sunriseTime')
            FNUSNRTOD=$(TZ=$FNUTIZ date --date="@$FNUSNRTOD" +%H:%M)
            FNUSNSTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].sunsetTime')
            FNUSNSTOD=$(TZ=$FNUTIZ date --date="@$FNUSNSTOD" +%H:%M)
            FNUSUMTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].summary')
            # Tomorrow
            FNUTMPW1K1=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].temperatureMax')
            FNUTMPW2K1=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].temperatureMin')
            FNUPRPTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].precipProbability')
            FNUPRPTOM=$(echo "$FNUPRPTOM*100" | bc | sed 's/\.00//')
            FNUPRTTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].precipType')
            if [ "$FNUPRTTOM" = "null" ]; then
                FNUPRTTOM=""
            else
                FNUPRTTOM=$(echo "chance of $FNUPRTTOM")
            fi
            FNUSNRTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].sunriseTime')
            FNUSNRTOM=$(TZ=$FNUTIZ date --date="@$FNUSNRTOM" +%H:%M)
            FNUSNSTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].sunsetTime')
            FNUSNSTOM=$(TZ=$FNUTIZ date --date="@$FNUSNSTOM" +%H:%M)
            FNUSUMWEK1=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].summary')
            clear
            echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
            echo ""
            echo ":: Current ::"
            echo -n "     Location:"
            echo "               $FNULOC" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
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
                        FNUDAYWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].time")
                        FNUDAYWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUDAYWEK[$FNUCANT]}" +%A)
                        FNUDAYWEK[$FNUCANT]=$(echo "${FNUDAYWEK[$FNUCANT]^}")
                        FNUTMPW1K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMax")
                        FNUTMPW2K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMin")
                        FNUSUMWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].summary")
                    done
                    FNUCANT=1
                    clear
                    echo "$FNUNAM - v$FNUVER :: powered by darksky.net"
                    echo ""
                    echo -n "Location:"
                    echo "               $FNULOC" | fmt -w $FNUCOL -c | sed -r '1s/^\s{10}/ /'
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
                    clear
                    exit
                ;;
                *)
                    continue
                ;;
            esac
        done
    fi
done
