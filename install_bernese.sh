#!/usr/bin/env bash
# ============================================================
#  Bernese GNSS Software 5.4 Automated Finish Step
# ============================================================

set -euo pipefail

export HOME=/home/bernese
export C=/home/bernese/BERN54

# ------------------------------------------------------------
# Install license
# ------------------------------------------------------------

if [ -f /opt/bernese-license/LICENSE.TXT ]; then
    cp /opt/bernese-license/LICENSE.TXT "${C}/LICENSE.TXT"
    chmod 644 "${C}/LICENSE.TXT"
fi

# ------------------------------------------------------------
# Load Bernese environment
# ------------------------------------------------------------

source /home/bernese/BERN54/LOADGPS.setvar

# ------------------------------------------------------------
# Add/update user environment, compile menu, compile programs,
# install example campaign, and install/update license file.
# ------------------------------------------------------------

perl "${C}/SCRIPT/EXE/configure.pm" \
    --qtBern=/usr/share/qt4 \
    --perl=/usr/bin/perl \
    --path="${C}" <<'EOF'
3
y

4

5

6

7
1

x
EOF