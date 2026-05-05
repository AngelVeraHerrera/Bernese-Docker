#!/usr/bin/env bash
# ============================================================
#  Bernese GNSS Software Docker Entrypoint
# ============================================================
#
#  Purpose:
#    - Initialize Bernese and Qt4 environment variables.
#    - Ensure required directory structure exists.
#    - Extract the Bernese installer bundle into INST if needed.
#    - Load Bernese environment when BERN54/LOADGPS.setvar exists.
#    - Keep the container usable for CLI, GUI and BPE workflows.
#
# ============================================================

set -e

# ------------------------------------------------------------
# Qt4 environment
# ------------------------------------------------------------

export QTDIR="${QTDIR:-/usr/share/qt4}"
export QTBERN="${QTBERN:-/usr/share/qt4}"
export QMAKESPEC="${QMAKESPEC:-/usr/share/qt4/mkspecs/linux-g++}"

# Avoid MIT-SHM issues when running Qt/X11 applications through Docker/WSLg.
export QT_X11_NO_MITSHM="${QT_X11_NO_MITSHM:-1}"

# ------------------------------------------------------------
# Bernese directory environment
# ------------------------------------------------------------

export C="${C:-${HOME}/BERN54}"
export U="${U:-${HOME}/GPSUSER54}"
export T="${T:-${HOME}/GPSWORK}"
export P="${P:-${HOME}/GPSDATA/CAMPAIGN54}"
export D="${D:-${HOME}/GPSDATA/DATAPOOL}"
export S="${S:-${HOME}/GPSDATA/SAVEDISK}"

# ------------------------------------------------------------
# PATH
# ------------------------------------------------------------

export PATH="${QTDIR}/bin:${C}/PGM:${C}/SCRIPT:${PATH}"

# ------------------------------------------------------------
# Directory validation/creation
# ------------------------------------------------------------

mkdir -p "${U}"
mkdir -p "${T}"
mkdir -p "${P}"
mkdir -p "${D}"
mkdir -p "${S}"

# ------------------------------------------------------------
# Permissions
# ------------------------------------------------------------
#
# Avoid recursive chmod at every startup. Recursive permission
# fixes on BERN54/GPSUSER54/GPSDATA are expensive once Bernese
# is installed.
#

fix_dir_permission() {
    local path="$1"

    if [ -d "${path}" ]; then
        chmod u+rwx,g+rwx "${path}" 2>/dev/null || true
    fi
}

fix_dir_permission "${C}"
fix_dir_permission "${U}"
fix_dir_permission "${T}"
fix_dir_permission "${P}"
fix_dir_permission "${D}"
fix_dir_permission "${S}"

if [ "${BERNESE_FIX_PERMISSIONS_RECURSIVE:-0}" = "1" ]; then
    chmod -R u+rwX,g+rwX "${T}" 2>/dev/null || true
    chmod -R u+rwX,g+rwX "${P}" 2>/dev/null || true
    chmod -R u+rwX,g+rwX "${D}" 2>/dev/null || true
    chmod -R u+rwX,g+rwX "${S}" 2>/dev/null || true
fi

# ------------------------------------------------------------
# Load Bernese environment if already installed
# ------------------------------------------------------------
#
# setup.sh/configure.pm creates LOADGPS.setvar during installation.
# Once it exists, loading it here makes later runs ready for Bernese.
#

if [ -f "${C}/LOADGPS.setvar" ]; then
    # shellcheck source=/dev/null
    source "/home/bernese/BERN54/LOADGPS.setvar"
fi

# ------------------------------------------------------------
# Useful runtime diagnostics
# ------------------------------------------------------------

if [ "${BERNESE_DEBUG:-0}" = "1" ]; then
    echo "============================================================"
    echo " Bernese Docker Environment"
    echo "============================================================"
    echo " HOME      = ${HOME}"
    echo " C / BERN  = ${C}"
    echo " U / USER  = ${U}"
    echo " T / WORK  = ${T}"
    echo " P / CAMP  = ${P}"
    echo " D / DATA  = ${D}"
    echo " S / SAVE  = ${S}"
    echo " QTDIR     = ${QTDIR}"
    echo " QTBERN    = ${QTBERN}"
    echo " QMAKESPEC = ${QMAKESPEC}"
    echo " DISPLAY   = ${DISPLAY:-<not set>}"

    if [ -f "${C}/LOADGPS.setvar" ]; then
        echo " LOADGPS   = ${C}/LOADGPS.setvar"
        echo " OS        = ${OS:-<not set>}"
        echo " OS_NAME   = ${OS_NAME:-<not set>}"
        echo " EXE       = ${EXE:-<not set>}"
        echo " XG        = ${XG:-<not set>}"
        echo " XQ        = ${XQ:-<not set>}"
        echo " FG        = ${FG:-<not set>}"
    else
        echo " LOADGPS   = <not installed yet>"
    fi

    echo "============================================================"
    echo "===== System ==============================================="
    whoami
    hostname
    cat /etc/os-release | head -6
    date
    cat /etc/timezone
    echo "===== Qt4 =================================================="
    echo "QTDIR=$QTDIR"
    echo "QTBERN=$QTBERN"
    echo "QMAKESPEC=$QMAKESPEC"
    which qmake || true
    qmake -v
    echo "===== Qt4 headers =========================================="
    ls -l /usr/include/qt4/QtCore/qglobal.h
    ls -l /usr/include/qt4/QtCore/QtCore
    ls -l /usr/include/qt4/QtGui/QHBoxLayout
    ls -l /usr/include/qt4/QtGui/QApplication
    ls -l /usr/include/qt4/Qt3Support/q3accel.h
    ls -l /usr/include/qt4/Qt3Support/q3socket.h
    ls -l /usr/include/qt4/Qt3Support/q3listbox.h
    echo "============================================================"
fi

exec "$@"