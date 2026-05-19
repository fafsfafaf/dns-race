#!/usr/bin/env bash
# dns-race — race the world's public DNS resolvers from your machine.
# Cloudflare, Google, Quad9, AdGuard, NextDNS, ControlD, OpenDNS, Yandex.
#
#   bash dns-race.sh                    # default domains
#   bash dns-race.sh google.com github.com cloudflare.com
#
set -u
VERSION="1.0.0"

if [ -t 1 ]; then
    B=$'\033[1m'; D=$'\033[2m'; R=$'\033[0m'
    G=$'\033[32m'; Y=$'\033[33m'; C=$'\033[36m'; M=$'\033[35m'
else B=""; D=""; R=""; G=""; Y=""; C=""; M=""; fi

command -v dig >/dev/null || { echo "dig required (apt install dnsutils / dnf install bind-utils)"; exit 1; }

# resolver list: name|primary_ip|secondary_ip
RESOLVERS=(
    "Cloudflare|1.1.1.1|1.0.0.1"
    "Google|8.8.8.8|8.8.4.4"
    "Quad9|9.9.9.9|149.112.112.112"
    "AdGuard|94.140.14.14|94.140.15.15"
    "NextDNS|45.90.28.0|45.90.30.0"
    "ControlD|76.76.2.0|76.76.10.0"
    "OpenDNS|208.67.222.222|208.67.220.220"
    "Yandex|77.88.8.8|77.88.8.1"
    "DNS.SB|185.222.222.222|45.11.45.11"
    "AliDNS|223.5.5.5|223.6.6.6"
)

if [ $# -gt 0 ]; then DOMAINS=("$@"); else
    DOMAINS=(google.com github.com cloudflare.com youtube.com wikipedia.org)
fi

ROUNDS=4

printf '\n%sdns-race v%s%s · %d resolvers · %d domains · %d rounds each\n\n' \
    "$B" "$VERSION" "$R" "${#RESOLVERS[@]}" "${#DOMAINS[@]}" "$ROUNDS"

# Header
printf '  %s%-12s%s' "$B" "RESOLVER" "$R"
for d in "${DOMAINS[@]}"; do printf '  %s%-14s%s' "$B" "$d" "$R"; done
printf '  %s%-8s%s\n' "$B" "AVG" "$R"
printf '  %s' "$D"
printf -- '─%.0s' {1..12}
for d in "${DOMAINS[@]}"; do printf '  '; printf -- '─%.0s' {1..14}; done
printf '  '; printf -- '─%.0s' {1..8}
printf '%s\n' "$R"

declare -A RESULTS_AVG

for entry in "${RESOLVERS[@]}"; do
    name="${entry%%|*}"
    rest="${entry#*|}"
    primary="${rest%%|*}"
    secondary="${rest##*|}"
    printf '  %s%-12s%s' "$C" "$name" "$R"

    SUM_ALL=0; COUNT_ALL=0
    for d in "${DOMAINS[@]}"; do
        SUM=0; OK=0
        for i in $(seq 1 $ROUNDS); do
            T=$(dig +noall +stats +time=2 +tries=1 @"$primary" "$d" 2>/dev/null | awk '/Query time/{print $4}')
            if [ -n "$T" ] && [ "$T" -ge 0 ] 2>/dev/null; then
                SUM=$((SUM + T)); OK=$((OK + 1))
            fi
        done
        if [ "$OK" -gt 0 ]; then
            AVG=$((SUM / OK))
            # color by latency
            if [ "$AVG" -lt 20 ]; then col="$G"
            elif [ "$AVG" -lt 60 ]; then col="$C"
            elif [ "$AVG" -lt 120 ]; then col="$Y"
            else col="$M"; fi
            printf '  %s%-14s%s' "$col" "${AVG} ms" "$R"
            SUM_ALL=$((SUM_ALL + AVG)); COUNT_ALL=$((COUNT_ALL + 1))
        else
            printf '  %s%-14s%s' "$Y" "fail" "$R"
        fi
    done

    if [ "$COUNT_ALL" -gt 0 ]; then
        TOTAL_AVG=$((SUM_ALL / COUNT_ALL))
        printf '  %s%-8s%s\n' "$B" "${TOTAL_AVG}ms" "$R"
        RESULTS_AVG["$name"]="$TOTAL_AVG"
    else
        printf '  %s%-8s%s\n' "$Y" "—" "$R"
    fi
done

# Winner
echo
WINNER=""
WINNER_MS=99999
for name in "${!RESULTS_AVG[@]}"; do
    ms="${RESULTS_AVG[$name]}"
    if [ "$ms" -lt "$WINNER_MS" ]; then
        WINNER="$name"; WINNER_MS="$ms"
    fi
done
[ -n "$WINNER" ] && printf '  %s🏆 fastest from your location:%s %s%s%s (%sms avg)\n\n' \
    "$B" "$R" "$G" "$WINNER" "$R" "$WINNER_MS"
