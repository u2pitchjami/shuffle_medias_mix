![shuffle_medias_mix](https://socialify.git.ci/u2pitchjami/shuffle_medias_mix/image?description=1&descriptionEditable=make%20a%20shuffle%20mix%20of%20medias%20with%20template&font=KoHo&language=1&logo=https%3A%2F%2Fgreen-berenice-35.tiiny.site%2Fimage2vector-3.svg&name=1&owner=1&pattern=Charlie%20Brown&stargazers=1&theme=Dark)
# Shuffle Medias Mix

[![Twitter](https://img.shields.io/twitter/follow/u2pitchjami.svg?style=social)](https://twitter.com/u2pitchjami)
![GitHub followers](https://img.shields.io/github/followers/u2pitchjami)
![Reddit User Karma](https://img.shields.io/reddit/user-karma/combined/u2pitchjami)



The purpose of this script is make a shuffle mix of medias with template


## Installation

### 1 - Clone the repository :
### 2 - Create and edit .config.cfg :


![image](https://github.com/user-attachments/assets/5f44acec-72f9-4b6a-8e0d-8a8e0aa1025e)


## Usage/Examples

### 1 - Create directories in the base

```bash
mkdir dir1
mkdir dir2
```    
### 2 - Create Template

```bash
template_creation.sh
```    
Create your templates by choosing directories (scenes) and clips numbers ex : 2-6 (means the script choose between 2 to 6 clips for the scene)

### 3 - Import Files

```bash
import_TVAI_OK.sh
regroup_files.sh
```    
Import files to scenes.

The files names must be : name_file_x_scene-xxxxxx.mp4 (can be change in conf).

The result : /base/scene/Name File 000001.mp4


### 4 - Check Files

```bash
check_files.sh
```    

Check files after import and make statistics (for video : fps, bitrate, resolution)

### 5 - Make a shuffle

```bash
check_files.sh
```  
Select a template and the script make an auto shuffle and merge if files are ok


## Authors

👤 **u2pitchjami**

* Twitter: [@u2pitchjami](https://twitter.com/u2pitchjami)
* Github: [@u2pitchjami](https://github.com/u2pitchjami)
* LinkedIn: [@thierry-beugnet-a7761672](https://linkedin.com/in/thierry-beugnet-a7761672)

