#!/bin/bash
# fnugg v0.32
# Made by Dr. Waldijk
# A simple weather script that fetches weather data from darksky.net.
# Read the README.md for more info, but you will find more info here below.
# By running this script you agree to the license terms.
# Config ----------------------------------------------------------------------------
FNUNAM="fnugg"
FNUVER="0.32"
FNUDIR="$HOME/.dokter/fnugg"
FNUFLG=$1
FNUNTC="2400"
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
# if [ -e $FNUDIR/fnulst ]; then
#     rm $FNUDIR/fnulst
# fi
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
        sudo dnf -y install curl jq fmt
    else
        echo "You need to install curl, jq and fmt."
        exit
    fi
elif [ ! -e /usr/bin/curl ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install curl
    else
        echo "You need to install curl."
        exit
    fi
elif [ ! -e /usr/bin/jq ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install jq
    else
        echo "You need to install jq."
        exit
    fi
elif [ ! -e /usr/bin/fmt ]; then
    FNUOSD=$(cat /etc/system-release | grep -oE '^[A-Z][a-z]+\s' | sed '1s/\s//')
    if [ "$FNUOSD" = "Fedora" ]; then
        sudo dnf -y install fmt
    else
        echo "You need to install fmt."
        exit
    fi
fi
# Functions -------------------------------------------------------------------------
small () {
    while :; do
        FNUSKYAPI=$(curl -s "https://api.darksky.net/forecast/$FNUSKY/$FNULAT,$FNULON?lang=$FNULAN&exclude=minutely,hourly,alerts,flags&units=$FNUNIT")
        FNUTIZ=$(echo "$FNUSKYAPI" | jq -r '.timezone')
        FNUCOL=$(tput cols)
        # Current
        FNUDAT=$(echo "$FNUSKYAPI" | jq -r '.currently.time')
        FNUDAT=$(TZ=$FNUTIZ date --date="@$FNUDAT" '+%Y-%m-%d %H:%M')
        FNUTMP=$(echo "$FNUSKYAPI" | jq -r '.currently.temperature')
        FNUTFL=$(echo "$FNUSKYAPI" | jq -r '.currently.apparentTemperature')
        FNUUVI=$(echo "$FNUSKYAPI" | jq -r '.currently.uvIndex')
        FNUHUM=$(echo "$FNUSKYAPI" | jq -r '.currently.humidity')
        FNUHUM=$(echo "$FNUHUM*100" | bc | sed 's/\.00//')
        FNUWND=$(echo "$FNUSKYAPI" | jq -r '.currently.windSpeed')
        FNUBRN=$(echo "$FNUSKYAPI" | jq -r '.currently.windBearing')
        FNUGST=$(echo "$FNUSKYAPI" | jq -r '.currently.windGust')
        FNUSUM=$(echo "$FNUSKYAPI" | jq -r '.currently.summary')
        if [[ "$FNUUVI" -ge "0" && "$FNUUVI" -le "2" ]]; then
            FNUUVIRSK="Low"
        elif [[ "$FNUUVI" -ge "3" && "$FNUUVI" -le "5" ]]; then
            FNUUVIRSK="Moderate"
        elif [[ "$FNUUVI" -ge "6" && "$FNUUVI" -le "7" ]]; then
            FNUUVIRSK="High"
        elif [[ "$FNUUVI" -ge "8" && "$FNUUVI" -le "10" ]]; then
            FNUUVIRSK="Very high"
        elif [[ "$FNUUVI" -ge "11" ]]; then
            FNUUVIRSK="Extreme"
        fi
        if [[ "$FNUBRN" -eq "null" ]]; then
            FNUBRN=""
        elif [[ "$FNUBRN" -eq "0" ]]; then
            FNUBRN="N"
        elif [[ "$FNUBRN" -ge "1" && "$FNUBRN" -le "89" ]]; then
            FNUBRN="NE"
        elif [[ "$FNUBRN" -eq "90" ]]; then
            FNUBRN="E"
        elif [[ "$FNUBRN" -ge "91" && "$FNUBRN" -le "179" ]]; then
            FNUBRN="SE"
        elif [[ "$FNUBRN" -eq "180" ]]; then
            FNUBRN="S"
        elif [[ "$FNUBRN" -ge "181" && "$FNUBRN" -le "269" ]]; then
            FNUBRN="SW"
        elif [[ "$FNUBRN" -eq "270" ]]; then
            FNUBRN="W"
        elif [[ "$FNUBRN" -ge "271" && "$FNUBRN" -le "359" ]]; then
            FNUBRN="NW"
        fi
        # Forecast
        FNUCANT=0
        until [ "$FNUCANT" -eq "7" ]; do
            FNUDAYWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].time")
            FNUDAYWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUDAYWEK[$FNUCANT]}" +%A)
            FNUDAYWEK[$FNUCANT]=$(echo "${FNUDAYWEK[$FNUCANT]^}")
            FNUTMPW1K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMax")
            FNUTMPW2K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMin")
            FNUPRPWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].precipProbability")
            FNUPRPWEK[$FNUCANT]=$(echo "${FNUPRPWEK[$FNUCANT]}*100" | bc | sed 's/\.00//')
            FNUPRTWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].precipType")
            if [ "${FNUPRTWEK[$FNUCANT]}" = "null" ]; then
                FNUPRTWEK[$FNUCANT]=""
            else
                FNUPRTWEK[$FNUCANT]=$(echo "chance of ${FNUPRTWEK[$FNUCANT]}")
            fi
            FNUWNDWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].windSpeed")
            FNUBRNWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].windBearing")
            if [[ "${FNUBRNWEK[$FNUCANT]}" -eq "null" ]]; then
                FNUBRNWEK[$FNUCANT]=""
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "0" ]]; then
                FNUBRNWEK[$FNUCANT]="N"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "1" && "${FNUBRNWEK[$FNUCANT]}" -le "89" ]]; then
                FNUBRNWEK[$FNUCANT]="NE"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "90" ]]; then
                FNUBRNWEK[$FNUCANT]="E"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "91" && "${FNUBRNWEK[$FNUCANT]}" -le "179" ]]; then
                FNUBRNWEK[$FNUCANT]="SE"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "180" ]]; then
                FNUBRNWEK[$FNUCANT]="S"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "181" && "${FNUBRNWEK[$FNUCANT]}" -le "269" ]]; then
                FNUBRNWEK[$FNUCANT]="SW"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "270" ]]; then
                FNUBRNWEK[$FNUCANT]="W"
            elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "271" && "${FNUBRNWEK[$FNUCANT]}" -le "359" ]]; then
                FNUBRNWEK[$FNUCANT]="NW"
            fi
            FNUSNRWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].sunriseTime")
            FNUSNRWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUSNRWEK[$FNUCANT]}" +%H:%M)
            FNUSNSWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].sunsetTime")
            FNUSNSWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUSNSWEK[$FNUCANT]}" +%H:%M)
            FNUSUMWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].summary")
            FNUCANT=$(expr $FNUCANT + 1)
        done
        FNUCANT=1
        FNUPAG="-1"
        while :; do
            clear
            echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
            echo ""
            echo ":: Location ::"
            echo "$FNULOC" | fmt -w $FNUCOL -c
            #echo "$FNUDAT"
            echo ""
            if [[ "$FNUPAG" = "-1" ]]; then
                echo ":: Current ::"
                echo "  Temperature: $FNUTMP°C"
                echo "   Feels like: $FNUTFL°C"
                echo "     UV Index: $FNUUVI ($FNUUVIRSK)"
                echo "     Humidity: $FNUHUM%"
                echo "         Wind: $FNUWND m/s ($FNUGST m/s) $FNUBRN"
                echo -n "      Summary:"
                echo "               $FNUSUM" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
            elif [[ "$FNUPAG" != "-1" ]]; then
                echo ":: ${FNUDAYWEK[$FNUPAG]} ::"
                echo "  Temperature: ${FNUTMPW1K[$FNUPAG]}°C (${FNUTMPW2K[$FNUPAG]}°C)"
                echo "Precipitation: ${FNUPRPWEK[$FNUPAG]}% ${FNUPRTWEK[$FNUPAG]}"
                echo "         Wind: ${FNUWNDWEK[$FNUPAG]} m/s ${FNUBRNWEK[$FNUPAG]}"
                echo "      Sunrise: ${FNUSNRWEK[$FNUPAG]}"
                echo "       Sunset: ${FNUSNSWEK[$FNUPAG]}"
                echo -n "      Summary:"
                echo "               ${FNUSUMWEK[$FNUPAG]}" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
            fi
            echo ""
            read -t $FNUREF -s -n1 -p "(N)ext / (P)revious / (R)efresh / (Q)uit " FNUQUT
            case "$FNUQUT" in
                [nN])
                    FNUPAG=$(expr $FNUPAG + 1)
                    if [[ "$FNUPAG" -gt "6" ]]; then
                        FNUPAG="6"
                    fi
                ;;
                [pP])
                    FNUPAG=$(expr $FNUPAG - 1)
                    if [[ "$FNUPAG" -lt "-1" ]]; then
                        FNUPAG="-1"
                    fi
                ;;
                [qQ])
                    break
                    FNUQIT="1"
                ;;
                *)
                    continue
                ;;
            esac
            if [[ "$FNUQIT" = "1" ]]; then
                FNUQIT="0"
                break
            fi
        done
        break
    done
}
large () {
    while :; do
        FNUSKYAPI=$(curl -s "https://api.darksky.net/forecast/$FNUSKY/$FNULAT,$FNULON?lang=$FNULAN&exclude=minutely,hourly,alerts,flags&units=$FNUNIT")
        FNUTIZ=$(echo "$FNUSKYAPI" | jq -r '.timezone')
        FNUCOL=$(tput cols)
        # Current
        FNUDAT=$(echo "$FNUSKYAPI" | jq -r '.currently.time')
        FNUDAT=$(TZ=$FNUTIZ date --date="@$FNUDAT" '+%Y-%m-%d %H:%M')
        FNUTMP=$(echo "$FNUSKYAPI" | jq -r '.currently.temperature')
        FNUTFL=$(echo "$FNUSKYAPI" | jq -r '.currently.apparentTemperature')
        FNUUVI=$(echo "$FNUSKYAPI" | jq -r '.currently.uvIndex')
        FNUHUM=$(echo "$FNUSKYAPI" | jq -r '.currently.humidity')
        FNUHUM=$(echo "$FNUHUM*100" | bc | sed 's/\.00//')
        FNUWND=$(echo "$FNUSKYAPI" | jq -r '.currently.windSpeed')
        FNUBRN=$(echo "$FNUSKYAPI" | jq -r '.currently.windBearing')
        FNUGST=$(echo "$FNUSKYAPI" | jq -r '.currently.windGust')
        FNUSUM=$(echo "$FNUSKYAPI" | jq -r '.currently.summary')
        if [[ "$FNUUVI" -ge "0" && "$FNUUVI" -le "2" ]]; then
            FNUUVIRSK="Low"
        elif [[ "$FNUUVI" -ge "3" && "$FNUUVI" -le "5" ]]; then
            FNUUVIRSK="Moderate"
        elif [[ "$FNUUVI" -ge "6" && "$FNUUVI" -le "7" ]]; then
            FNUUVIRSK="High"
        elif [[ "$FNUUVI" -ge "8" && "$FNUUVI" -le "10" ]]; then
            FNUUVIRSK="Very high"
        elif [[ "$FNUUVI" -ge "11" ]]; then
            FNUUVIRSK="Extreme"
        fi
        if [[ "$FNUBRN" -eq "null" ]]; then
            FNUBRN=""
        elif [[ "$FNUBRN" -eq "0" ]]; then
            FNUBRN="N"
        elif [[ "$FNUBRN" -ge "1" && "$FNUBRN" -le "89" ]]; then
            FNUBRN="NE"
        elif [[ "$FNUBRN" -eq "90" ]]; then
            FNUBRN="E"
        elif [[ "$FNUBRN" -ge "91" && "$FNUBRN" -le "179" ]]; then
            FNUBRN="SE"
        elif [[ "$FNUBRN" -eq "180" ]]; then
            FNUBRN="S"
        elif [[ "$FNUBRN" -ge "181" && "$FNUBRN" -le "269" ]]; then
            FNUBRN="SW"
        elif [[ "$FNUBRN" -eq "270" ]]; then
            FNUBRN="W"
        elif [[ "$FNUBRN" -ge "271" && "$FNUBRN" -le "359" ]]; then
            FNUBRN="NW"
        fi
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
        FNUWNDTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].windSpeed')
        FNUBRNTOD=$(echo "$FNUSKYAPI" | jq -r '.daily.data[0].windBearing')
        if [[ "$FNUBRNTOD" -eq "null" ]]; then
            FNUBRNTOD=""
        elif [[ "$FNUBRNTOD" -eq "0" ]]; then
            FNUBRNTOD="N"
        elif [[ "$FNUBRNTOD" -ge "1" && "$FNUBRNTOD" -le "89" ]]; then
            FNUBRNTOD="NE"
        elif [[ "$FNUBRNTOD" -eq "90" ]]; then
            FNUBRNTOD="E"
        elif [[ "$FNUBRNTOD" -ge "91" && "$FNUBRNTOD" -le "179" ]]; then
            FNUBRNTOD="SE"
        elif [[ "$FNUBRNTOD" -eq "180" ]]; then
            FNUBRNTOD="S"
        elif [[ "$FNUBRNTOD" -ge "181" && "$FNUBRNTOD" -le "269" ]]; then
            FNUBRNTOD="SW"
        elif [[ "$FNUBRNTOD" -eq "270" ]]; then
            FNUBRNTOD="W"
        elif [[ "$FNUBRNTOD" -ge "271" && "$FNUBRNTOD" -le "359" ]]; then
            FNUBRNTOD="NW"
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
        FNUWNDTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].windSpeed')
        FNUBRNTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].windBearing')
        if [[ "$FNUBRNTOM" -eq "null" ]]; then
            FNUBRNTOM=""
        elif [[ "$FNUBRNTOM" -eq "0" ]]; then
            FNUBRNTOM="N"
        elif [[ "$FNUBRNTOM" -ge "1" && "$FNUBRNTOM" -le "89" ]]; then
            FNUBRNTOM="NE"
        elif [[ "$FNUBRNTOM" -eq "90" ]]; then
            FNUBRNTOM="E"
        elif [[ "$FNUBRNTOM" -ge "91" && "$FNUBRNTOM" -le "179" ]]; then
            FNUBRNTOM="SE"
        elif [[ "$FNUBRNTOM" -eq "180" ]]; then
            FNUBRNTOM="S"
        elif [[ "$FNUBRNTOM" -ge "181" && "$FNUBRNTOM" -le "269" ]]; then
            FNUBRNTOM="SW"
        elif [[ "$FNUBRNTOM" -eq "270" ]]; then
            FNUBRNTOM="W"
        elif [[ "$FNUBRNTOM" -ge "271" && "$FNUBRNTOM" -le "359" ]]; then
            FNUBRNTOM="NW"
        fi
        FNUSNRTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].sunriseTime')
        FNUSNRTOM=$(TZ=$FNUTIZ date --date="@$FNUSNRTOM" +%H:%M)
        FNUSNSTOM=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].sunsetTime')
        FNUSNSTOM=$(TZ=$FNUTIZ date --date="@$FNUSNSTOM" +%H:%M)
        FNUSUMWEK1=$(echo "$FNUSKYAPI" | jq -r '.daily.data[1].summary')
        # Notification
        #if [ "$FNUFLG" = "notification" ]; then
        #    FNUNTC=$(expr $FNUNTC + $FNUREF)
        #    if [ "$FNUNTC" -eq "3000" ]; then
        #        FNUNOT=$(echo "$FNULOC" | cut -d , -f 1)
        #        notify-send "$FNUNOT" "$FNUTMP°C ($FNUTFL°C)"
        #        FNUNTC="0"
        #    fi
        #fi
        clear
        echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
        echo ""
        echo ":: Location ::"
        echo "$FNULOC" | fmt -w $FNUCOL -c
        #echo "$FNUDAT"
        echo ""
        echo ":: Current ::"
        echo "  Temperature: $FNUTMP°C"
        echo "   Feels like: $FNUTFL°C"
        echo "     UV Index: $FNUUVI ($FNUUVIRSK)"
        echo "     Humidity: $FNUHUM%"
        echo "         Wind: $FNUWND m/s ($FNUGST m/s) $FNUBRN"
        echo -n "      Summary:"
        echo "               $FNUSUM" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
        echo ""
        echo ":: Today ::"
        echo "  Temperature: $FNUTMPW1K0°C ($FNUTMPW2K0°C)"
        echo "Precipitation: $FNUPRPTOD% $FNUPRTTOD"
        echo "         Wind: $FNUWNDTOD m/s $FNUBRNTOD"
        echo "      Sunrise: $FNUSNRTOD"
        echo "       Sunset: $FNUSNSTOD"
        echo -n "      Summary:"
        echo "               $FNUSUMTOD" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
        echo ""
        echo ":: Tomorrow ::"
        echo "  Temperature: $FNUTMPW1K1°C ($FNUTMPW2K1°C)"
        echo "Precipitation: $FNUPRPTOM% $FNUPRTTOM"
        echo "         Wind: $FNUWNDTOM m/s $FNUBRNTOM"
        echo "      Sunrise: $FNUSNRTOM"
        echo "       Sunset: $FNUSNSTOM"
        echo -n "      Summary:"
        echo "               $FNUSUMWEK1" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
        echo ""
        echo "(Q)uit |    6-day   | (Any key)"
        read -t $FNUREF -s -n1 -p "       | (f)orecast | to refresh: " FNUQUT
        case "$FNUQUT" in
            [fF])
                FNUCANT=1
                until [ "$FNUCANT" -eq "7" ]; do
                    FNUCANT=$(expr $FNUCANT + 1)
                    FNUDAYWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].time")
                    FNUDAYWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUDAYWEK[$FNUCANT]}" +%A)
                    FNUDAYWEK[$FNUCANT]=$(echo "${FNUDAYWEK[$FNUCANT]^}")
                    FNUTMPW1K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMax")
                    FNUTMPW2K[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].temperatureMin")
                    FNUPRPWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].precipProbability")
                    FNUPRPWEK[$FNUCANT]=$(echo "${FNUPRPWEK[$FNUCANT]}*100" | bc | sed 's/\.00//')
                    FNUPRTWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].precipType")
                    if [ "${FNUPRTWEK[$FNUCANT]}" = "null" ]; then
                        FNUPRTWEK[$FNUCANT]=""
                    else
                        FNUPRTWEK[$FNUCANT]=$(echo "chance of ${FNUPRTWEK[$FNUCANT]}")
                    fi
                    FNUWNDWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].windSpeed")
                    FNUBRNWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].windBearing")
                    if [[ "${FNUBRNWEK[$FNUCANT]}" -eq "null" ]]; then
                        FNUBRNWEK[$FNUCANT]=""
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "0" ]]; then
                        FNUBRNWEK[$FNUCANT]="N"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "1" && "${FNUBRNWEK[$FNUCANT]}" -le "89" ]]; then
                        FNUBRNWEK[$FNUCANT]="NE"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "90" ]]; then
                        FNUBRNWEK[$FNUCANT]="E"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "91" && "${FNUBRNWEK[$FNUCANT]}" -le "179" ]]; then
                        FNUBRNWEK[$FNUCANT]="SE"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "180" ]]; then
                        FNUBRNWEK[$FNUCANT]="S"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "181" && "${FNUBRNWEK[$FNUCANT]}" -le "269" ]]; then
                        FNUBRNWEK[$FNUCANT]="SW"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -eq "270" ]]; then
                        FNUBRNWEK[$FNUCANT]="W"
                    elif [[ "${FNUBRNWEK[$FNUCANT]}" -ge "271" && "${FNUBRNWEK[$FNUCANT]}" -le "359" ]]; then
                        FNUBRNWEK[$FNUCANT]="NW"
                    fi
                    FNUSNRWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].sunriseTime")
                    FNUSNRWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUSNRWEK[$FNUCANT]}" +%H:%M)
                    FNUSNSWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].sunsetTime")
                    FNUSNSWEK[$FNUCANT]=$(TZ=$FNUTIZ date --date="@${FNUSNSWEK[$FNUCANT]}" +%H:%M)
                    FNUSUMWEK[$FNUCANT]=$(echo "$FNUSKYAPI" | jq -r ".daily.data[$FNUCANT].summary")
                done
                FNUCANT=1
                clear
                echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
                echo ""
                echo ":: Location ::"
                echo "$FNULOC" | fmt -w $FNUCOL -c
                echo ""
                until [ "$FNUCANT" -eq "4" ]; do
                    FNUCANT=$(expr $FNUCANT + 1)
                    echo ":: ${FNUDAYWEK[$FNUCANT]} ::"
                    echo "  Temperature: ${FNUTMPW1K[$FNUCANT]}°C (${FNUTMPW2K[$FNUCANT]}°C)"
                    echo "Precipitation: ${FNUPRPWEK[$FNUCANT]}% ${FNUPRTWEK[$FNUCANT]}"
                    echo "         Wind: ${FNUWNDWEK[$FNUCANT]} m/s ${FNUBRNWEK[$FNUCANT]}"
                    echo "      Sunrise: ${FNUSNRWEK[$FNUCANT]}"
                    echo "       Sunset: ${FNUSNSWEK[$FNUCANT]}"
                    echo -n "      Summary:"
                    echo "               ${FNUSUMWEK[$FNUCANT]}" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
                    echo ""
                done
                read -p "Press any key to continue... " -n1 -s
                clear
                echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
                echo ""
                echo ":: Location ::"
                echo "$FNULOC" | fmt -w $FNUCOL -c
                echo ""
                until [ "$FNUCANT" -eq "7" ]; do
                    FNUCANT=$(expr $FNUCANT + 1)
                    echo ":: ${FNUDAYWEK[$FNUCANT]} ::"
                    echo "  Temperature: ${FNUTMPW1K[$FNUCANT]}°C (${FNUTMPW2K[$FNUCANT]}°C)"
                    echo "Precipitation: ${FNUPRPWEK[$FNUCANT]}% ${FNUPRTWEK[$FNUCANT]}"
                    echo "         Wind: ${FNUWNDWEK[$FNUCANT]} m/s ${FNUBRNWEK[$FNUCANT]}"
                    echo "      Sunrise: ${FNUSNRWEK[$FNUCANT]}"
                    echo "       Sunset: ${FNUSNSWEK[$FNUCANT]}"
                    echo -n "      Summary:"
                    echo "               ${FNUSUMWEK[$FNUCANT]}" | fmt -w $FNUCOL -c | sed -r '1s/^\s{15}/ /'
                    echo ""
                done
                read -p "Press any key to continue... " -n1 -s
            ;;
            [qQ])
                clear
                break
            ;;
            *)
                continue
            ;;
        esac
    done
}
# -----------------------------------------------------------------------------------
while :; do
#    clear
#    echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
#    echo ""
#    echo "Press any key to check the weather"
#    echo -n "Q. Quit "
#    read -p "" -s -n1 FNUKEY
#    if [ "$FNUKEY" = "q" ] || [ "$FNUKEY" = "Q" ]; then
#        clear
#        break
#    else
#        FNUKEY=""
#    fi
    while :; do
        clear
        echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
        echo ""
        echo "Search for city or (q)uit:"
        read -p "> " FNUSRC
        # If the city name has a space in it, add underscore. If the city name has ÅÄÖ or ÆØÅ in it, change it to OAA.
        FNUSRC=$(echo $FNUSRC | sed -r 's/\s/_/' | sed -r 's/[æÆ]/a/' | sed -r 's/[øØ]/o/' | sed -r 's/[åÅ]/a/' | sed -r 's/[äÄ]/a/' | sed -r 's/[öÖ]/o/')
        # Semi-secret way to quit.
        if [ "$FNUSRC" = "q" ] || [ "$FNUSRC" = "Q" ]; then
            clear
            exit
        fi
        # If nothing entered, try again.
        if [ -z "$FNUSRC" ]; then
            clear
            echo "Butterfingers!"
            sleep 3s
        else
            break
        fi
    done
    # Find coordinated
    FNUMAPAPI=$(curl -s "https://api.mapbox.com/geocoding/v5/mapbox.places/$FNUSRC.json?access_token=$FNUMAP&types=place")
    FNULST=$(echo "$FNUMAPAPI" | jq -r '.features[].place_name' | nl -w1 -s'. ')
    FNUCNT=$(echo "$FNULST" | wc -l)
    if [ -n "$FNULST" ]; then
        if [ "$FNUCNT" -gt "1" ]; then
            clear
            echo "$FNUNAM - v$FNUVER :: powered by darksky & mapbox"
            echo ""
            echo "$FNULST"
            echo ""
            echo "B. Back to search  |  Q. Quit"
            echo ""
            read -p "Enter option: " -s -n1 FNUKEY
        else
            FNUKEY="1"
        fi
        if [ "$FNUKEY" = "q" ] || [ "$FNUKEY" = "Q" ]; then
            clear
            break
        elif [ "$FNUKEY" = "b" ] || [ "$FNUKEY" = "B" ]; then
            continue
        else
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
                        FNULAT=$(echo "$FNUMAPAPI" | jq -r ".features[$FNUKEY].center[1]")
                        # Longitude
                        FNULON=$(echo "$FNUMAPAPI" | jq -r ".features[$FNUKEY].center[0]")
                    ;;
                    [qQ])
                        clear
                        break
                    ;;
                esac
                # Functions
                if [[ "$FNUFLG" = "small" ]] || [[ -z "$FNUFLG" ]]; then
                    small
                elif [[ "$FNUFLG" = "large" ]]; then
                    large
                fi
            fi
        fi
    else
        clear
        echo "Butterfingers!"
        sleep 3s
    fi
done
