<a href="http://www.bridgelab.info"><img src="https://www.bridge-lab.org/storage/329/9f17e7e8-434b-4d67-85f7-bc57bcd496cc/bridge-logo.png"></a>

## 🐳 Docker Setup

### Step 1: Install Docker
- <b>macOS / Windows</b>: <span style="color:blue">[Download Docker Desktop](https://www.docker.com/products/docker-desktop/)</span>  
- <b>Linux</b>: Install Docker Engine via your package manager (`apt`, `yum`, etc.)  

### Step 2: Check Installation 
- Verify installation by running:
```bash
docker --version
```
---
## 📥 Freesurfer 6.0 Docker Container Setup

#### Step 1: Download This Repo
- Download the zip file by navigating to the green Code button and selecting Download ZIP
- Or install via CLI by doing

```
gh repo clone muscbridge/freesurfer-6.0-docker
```
- Unzip the folder and, move it to the location of your choice
-- This could be Desktop, Applications, or any other folder on your machine where you would like to store git repositories

#### Step 2: Build the Docker image and install
- Open a Terminal window and change your directory to location you chose in the previous step
-- Replace `/path/to/freesurfer-6.0-docker` with your freesurfer-6.0-docker folder path

```
cd /path/to/freesurfer-6.0-docker
docker build -t freesurfer:6.0 .
./install.sh
```
---
## 🧠 Run Freesurfer on your data
- Input the following command into your terminal, being sure to change the paths to your preferred input and output paths
```
freesurfer-docker /path/to/BIDS /path/to/output
```
