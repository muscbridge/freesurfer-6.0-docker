<a href="http://www.bridgelab.info" target="_blank"><img src="https://www.bridge-lab.org/storage/329/9f17e7e8-434b-4d67-85f7-bc57bcd496cc/bridge-logo.png"></a>

## ✦ Requirements: Docker
- <b>macOS / Windows</b>: <span style="color:blue">[Download Docker Desktop](https://www.docker.com/products/docker-desktop/)</span>  
- <b>Linux</b>: Install Docker Engine via your package manager (`apt`, `yum`, etc.)  

- Verify installation by running:
```bash
docker --version
```
---
## ✦ Pull the Docker Image

```
docker pull regularsizedryn/freesurfer-6.0-docker:1.0
```

---
## ✦ Run Freesurfer on your data

```
freesurfer-docker /path/to/BIDS /path/to/output
```
