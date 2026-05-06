<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Docker][docker-shield]][docker-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<h1 align="center">Bernese-Docker</h1>

<p align="center">
Dockerized environment for Bernese GNSS Software reproducible execution. <br />
Includes Ubuntu 18.04, Qt4, Fortran, Perl, RNXCMP/CRX2RNX, X11/WSLg support and optional shared data folders.
<br />
<br />
<a href="http://www.bernese.unibe.ch/">Bernese GNSS Software</a>
·
<a href="https://github.com/AngelVeraHerrera/Bernese54-Docker/issues">Report Bug</a>
·
<a href="https://github.com/AngelVeraHerrera/Bernese54-Docker/issues">Request Feature</a>
</p>

---

## 📖 About This Repository

This repository provides a **Dockerized runtime/build-compatible environment** for **Bernese GNSS Software 5.4**.

The image is based on **Ubuntu 18.04** because Bernese 5.4 depends on **Qt4**, which is no longer easily available in modern Ubuntu versions. The container includes the required compiler, Perl, Qt4 headers/libraries, X11/WSLg GUI support, and Hatanaka RINEX conversion tools.

- ✅ Ubuntu 18.04 base image for native Qt4 compatibility
- ✅ Qt 4.8.7 with Qt3Support headers
- ✅ GNU Fortran, GCC/G++, Make and Perl
- ✅ RNXCMP tools: `CRX2RNX`, `RNX2CRX`
- ✅ X11/WSLg support for Bernese GUI
- ✅ Optional shared folders for `GPSWORK`, `EXPORT` and `GPSDATA`
- ✅ Bernese installation automation through `expect` and shell scripts
- ✅ Suitable for reproducible private/internal environments

> ⚠️ **Important:** This repository does **not** include Bernese GNSS Software, ISO files, license files, campaigns, or private GNSS data. These files are proprietary/private and must be provided locally by the authorized user.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📦 Private Files Required

Before building the image, place the Bernese installer ISO and license file locally in:

```text
Bernese54/
├─ BSW54Unx_2023-10-16.iso
└─ LICENSE_full.TXT
```

These files are ignored by Git and must **not** be uploaded to GitHub.

Expected local structure:

```text
Bernese54-Docker/
├─ Dockerfile
├─ entrypoint.sh
├─ build.sh
├─ prepare_bernese.exp
├─ install_bernese.sh
├─ run_env_cli.sh
├─ run_env_gui.sh
├─ run_bernese_gui.sh
├─ .dockerignore
├─ .gitignore
├─ README.md
└─ Bernese54/
   ├─ BSW54Unx_2023-10-16.iso
   └─ LICENSE_full.TXT
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🧩 What Is Installed in the Image

The Docker image installs and configures:

```text
/home/bernese/BERN54      Bernese software installation
/home/bernese/GPSUSER54   Bernese user environment
/home/bernese/GPSDATA     Internal example campaign/data area
/home/bernese/GPSWORK     Working directory
```

The following tools are also available in the image:

```text
/usr/share/qt4/bin/qmake
/usr/local/bin/CRX2RNX
/usr/local/bin/RNX2CRX
/usr/local/bin/crx2rnx
/usr/local/bin/rnx2crx
```

The container runs internally in **UTC**.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<a name="build-top"></a>
## 🛠️ Build Instructions

Build the image from the repository root:

```bash
./build.sh
```

Or manually:

```bash
docker build \
  --build-arg HTTP_PROXY="${HTTP_PROXY:-}" \
  --build-arg HTTPS_PROXY="${HTTPS_PROXY:-}" \
  --build-arg NO_PROXY="${NO_PROXY:-}" \
  -t bernese54-runtime \
  .
```

For a fully clean rebuild without cache:

```bash
docker rmi -f bernese54-runtime 2>/dev/null || true
docker builder prune -af

docker build --no-cache --pull -t bernese54-runtime .
```

Building the image may take some time because the Bernese menu and Fortran programs are compiled during the Docker build.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🧹 Docker Cleanup Commands

List Docker images:

```bash
docker images
```

Show Docker disk usage:

```bash
docker system df
```

Clean build cache:

```bash
docker builder prune -af
```

Clean stopped containers, unused networks, dangling images and build cache:

```bash
docker system prune -af
```

More aggressive cleanup, including unused Docker volumes:

```bash
docker system prune -af --volumes
```

Remove the Bernese image:

```bash
docker rmi -f bernese54-runtime
```

> ⚠️ Do not use `--volumes` if you store important data in Docker-managed volumes. Host folders such as `~/bernese54-shared` are normal filesystem folders and are not removed by `docker system prune`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📁 Shared Folder Model

The Bernese software itself is installed **inside the Docker image**.

Therefore, these directories should **not** be bind-mounted during normal use:

```text
/home/bernese/BERN54
/home/bernese/GPSUSER54
/home/bernese/INST
```

Mounting them from the host would hide the installed/internal image content.

The default shared folder is:

```text
~/bernese54-shared/
```

Always shared:

```text
~/bernese54-shared/GPSWORK -> /home/bernese/GPSWORK
~/bernese54-shared/EXPORT  -> /home/bernese/EXPORT
```

Optionally shared with `--gpsdata`:

```text
~/bernese54-shared/GPSDATA -> /home/bernese/GPSDATA
```

> ⚠️ If `--gpsdata` is used with an empty host `GPSDATA` folder, it will hide the internal example campaign installed inside the image.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Run in CLI Mode

Run the Bernese environment in CLI/BPE mode:

```bash
./run_env_cli.sh
```

Run CLI mode with external `GPSDATA` mounted from the host:

```bash
./run_env_cli.sh --gpsdata
```

Inside the container, useful checks are:

```bash
source /home/bernese/BERN54/LOADGPS.setvar

echo "$C"
echo "$U"
echo "$T"
echo "$P"
echo "$D"
echo "$S"

which G
which CRX2RNX
qmake -v
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🖥️ Run GUI Environment

Run a shell with GUI/X11/WSLg support:

```bash
./run_env_gui.sh
```

Run GUI environment with external `GPSDATA` mounted from the host:

```bash
./run_env_gui.sh --gpsdata
```

Inside the container, launch Bernese manually:

```bash
G &
```

Useful GUI diagnostics:

```bash
echo "$DISPLAY"
echo "$QT_X11_NO_MITSHM"
which G
```

The environment sets:

```text
QT_X11_NO_MITSHM=1
```

to avoid common MIT-SHM issues when running Qt/X11 applications through Docker and WSLg.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Run Bernese GUI Directly

Launch the Bernese GUI directly:

```bash
./run_bernese_gui.sh
```

Launch directly with external `GPSDATA` mounted:

```bash
./run_bernese_gui.sh --gpsdata
```

If the GUI starts but appears empty or reports missing menu files, check that `GPSUSER54` is not being mounted from the host. The internal file must exist:

```bash
ls -lh /home/bernese/GPSUSER54/PAN/MENU.INP
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ✅ Validation Checklist

After building the image, run:

```bash
./run_env_cli.sh
```

Inside the container:

```bash
source /home/bernese/BERN54/LOADGPS.setvar

echo "C=$C"
echo "U=$U"
echo "T=$T"
echo "P=$P"
echo "D=$D"
echo "S=$S"
echo "EXE=$EXE"
echo "XG=$XG"
echo "XQ=$XQ"

which G
which CRX2RNX
qmake -v

ls -lh /home/bernese/GPSUSER54/PAN/MENU.INP
ls -lh /home/bernese/BERN54/LICENSE.TXT
ls -lh /home/bernese/BERN54/MENU/MENUCOMP.log
ls -lh /home/bernese/BERN54/SCRIPT/EXE/COMPLINK.log
```

Search for relevant build errors:

```bash
grep -nEi "error|fatal|failed|cannot|undefined" \
  /home/bernese/BERN54/MENU/MENUCOMP.log | tail -20 || true

grep -nEi "error|fatal|failed|cannot|undefined" \
  /home/bernese/BERN54/SCRIPT/EXE/COMPLINK.log | tail -20 || true
```

Expected key files:

```text
/home/bernese/BERN54/LOADGPS.setvar
/home/bernese/BERN54/SCRIPT/EXE/G
/home/bernese/GPSUSER54/PAN/MENU.INP
/home/bernese/BERN54/LICENSE.TXT
/usr/local/bin/CRX2RNX
/usr/share/qt4/bin/qmake
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📤 Export Internal Folders

The installed software and user environment live inside the image. If you want a host-visible copy for inspection or backup, use an export folder instead of mounting over the internal directories.

Recommended export target:

```text
~/bernese54-shared/EXPORT/
```

Example manual export from inside a container:

```bash
mkdir -p /home/bernese/EXPORT/BERN54
mkdir -p /home/bernese/EXPORT/GPSUSER54

rsync -a --delete /home/bernese/BERN54/ /home/bernese/EXPORT/BERN54/
rsync -a --delete /home/bernese/GPSUSER54/ /home/bernese/EXPORT/GPSUSER54/
```

Do not mount:

```text
/home/bernese/BERN54
/home/bernese/GPSUSER54
```

unless you explicitly want to replace the image-internal installation with host-side content.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 💾 Moving the Image to Another Computer

Save the image:

```bash
docker save bernese54-runtime | gzip > bernese54-runtime.tar.gz
```

Load it on another computer:

```bash
gunzip -c bernese54-runtime.tar.gz | docker load
```

Then copy the runtime scripts:

```text
run_env_cli.sh
run_env_gui.sh
run_bernese_gui.sh
```

and run as usual:

```bash
./run_env_cli.sh
./run_bernese_gui.sh
```

> ⚠️ The generated Docker image may contain Bernese software and license data. Keep it private and distribute it only according to your Bernese license terms.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🔒 Security and License Notes

This Git repository is intended to contain only the Docker environment and automation scripts.

Do **not** commit:

```text
Bernese54/
*.iso
LICENSE_full.TXT
LICENSE.TXT
BERN54/
GPSDATA/
GPSUSER54/
GPSWORK/
INST/
```

The `.gitignore` is configured to avoid accidental inclusion of licensed/private files, but always verify before pushing:

```bash
git status --short
git ls-files | grep -Ei 'iso|license|BERN54|GPSDATA|GPSUSER54|GPSWORK|INST|\.tgz|\.tar\.gz'
```

The repository itself may be distributed under the MIT License, but Bernese GNSS Software and its license file are not part of this repository and are governed by their own license terms.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License

Distributed under the MIT License. See the full text in the [`LICENSE`](LICENSE) file for more information.

This license applies only to the Dockerfiles, scripts and documentation in this repository. It does not apply to Bernese GNSS Software, license files, GNSS data, campaigns or third-party proprietary materials.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Acknowledgments

* [Bernese GNSS Software](http://www.bernese.unibe.ch/)
* [Astronomical Institute of the University of Bern](https://www.aiub.unibe.ch/)
* [RNXCMP / CRX2RNX by GSI](https://terras.gsi.go.jp/ja/crx2rnx.html)
* [Docker](https://www.docker.com/)
* [Royal Institute and Observatory of the Spanish Navy (San Fernando, Spain)](https://armada.defensa.gob.es/ArmadaPortal/page/Portal/ArmadaEspannola/cienciaobservatorio/prefLang-es/)
* [MIT License](https://choosealicense.com/licenses/mit/)
* [Shields](https://shields.io)
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[docker-shield]: https://img.shields.io/badge/-Docker-blue?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: https://www.docker.com/
[license-shield]: https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge
[license-url]: https://opensource.org/licenses/MIT
