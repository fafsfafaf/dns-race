# dns-race

> **Race 10 public DNS resolvers from your machine.** Cloudflare vs Google vs Quad9 vs AdGuard vs NextDNS vs ControlD vs OpenDNS vs Yandex vs DNS.SB vs AliDNS — see which one is actually fastest *from where you sit*.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/shell-bash-1f425f.svg)](#)
[![Resolvers: 10](https://img.shields.io/badge/resolvers-10-blue.svg)](#)
[![Stars](https://img.shields.io/github/stars/fafsfafaf/dns-race?style=social)](https://github.com/fafsfafaf/dns-race/stargazers)

```bash
curl -fsSL https://raw.githubusercontent.com/fafsfafaf/dns-race/master/dns-race.sh | bash
```

## Demo

Recorded with [asciinema](https://asciinema.org/). View it locally:

```bash
# install asciinema if needed: pip install asciinema
asciinema play demo.cast
```

Or upload to asciinema.org for an embeddable badge:

```bash
asciinema auth      # one-time, opens browser
asciinema upload demo.cast
```

## Why

"Cloudflare is the fastest DNS" — sure, *on average*. But from your specific ISP, in your specific city, at this specific time, it might not be. `dns-race` measures it in 10 seconds.

## Output

```
dns-race v1.0.0 · 10 resolvers · 5 domains · 4 rounds each

  RESOLVER      google.com      github.com      cloudflare.com  youtube.com     wikipedia.org   AVG
  ────────────  ──────────────  ──────────────  ──────────────  ──────────────  ──────────────  ────────
  Cloudflare    8 ms            12 ms           4 ms            10 ms           14 ms           9ms
  Google        18 ms           22 ms           19 ms           14 ms           24 ms           19ms
  Quad9         12 ms           20 ms           15 ms           18 ms           22 ms           17ms
  AdGuard       28 ms           32 ms           30 ms           29 ms           35 ms           30ms
  NextDNS       42 ms           48 ms           41 ms           44 ms           50 ms           45ms
  ControlD      35 ms           40 ms           36 ms           38 ms           42 ms           38ms
  OpenDNS       16 ms           24 ms           18 ms           20 ms           28 ms           21ms
  Yandex        50 ms           80 ms           60 ms           55 ms           75 ms           64ms

  🏆 fastest from your location: Cloudflare (9ms avg)
```

Latency is color-coded: green <20ms, cyan <60ms, yellow <120ms, magenta ≥120ms.

## Custom domains

```bash
bash dns-race.sh duckduckgo.com hetzner.com myshop.dev
```

## Resolvers tested

| Resolver | Primary | Privacy claim |
|----------|---------|---------------|
| Cloudflare | 1.1.1.1 | No logging |
| Google | 8.8.8.8 | Logs anonymized 24-48h |
| Quad9 | 9.9.9.9 | Blocks malicious domains |
| AdGuard | 94.140.14.14 | Blocks ads + trackers |
| NextDNS | 45.90.28.0 | Customizable, free tier |
| ControlD | 76.76.2.0 | Customizable |
| OpenDNS | 208.67.222.222 | Cisco, family filter avail. |
| Yandex | 77.88.8.8 | Russian-based |
| DNS.SB | 185.222.222.222 | No logging, EU |
| AliDNS | 223.5.5.5 | Alibaba, fast in APAC |

## Dependencies

`dig` (from `dnsutils` / `bind-utils`).

```bash
# Debian/Ubuntu
sudo apt install dnsutils
# RHEL/Fedora
sudo dnf install bind-utils
# Alpine
sudo apk add bind-tools
```

## License

MIT
