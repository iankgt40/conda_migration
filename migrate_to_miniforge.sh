#!/bin/bash

# Using bash for now, may need to make it POSIX compliant later

# Future thoughts - maybe set up flags/params for desired distro (other than miniforge), vars for homedir and/or desired conda location
# Should I be pedantic and add logic to determine/set the paths for "cp", "sed", "curl", etc.

# Need to insert if exists logic here

sed -i.bak '/anaconda/d' test_environment.yml 
sed -i.bak2 's/defaults/conda-forge/g' test_environment.yml
sed -i.bak3 's/=[^=]*//2g' test_environment.yml 

CONFIGDIRS="/home/ian/.condarc /home/ian/.anaconda /home/ian/.cache/pip"
for FILE in ${CONFIGDIRS}; do  if [ -d $FILE ]; then mv $FILE{,.bak}; fi; done

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh

# After this, you need to type yes to agree the terms and where to install miniforge. The default location is miniforge3 under your home which should NOT be where you install it. 
# If you must install it to the exact same place your Anaconda install was, move that install aside for now. You don’t want to delete it yet.

# Also remember we suggest you do NOT let the install add automatic activation of your Miniforge to your login file (e.g. .bashrc) since they causes problems with other programs like Xvnc and OpenOffice.
# After the install is done we need make sure only the proper channels are configured. Check the list created in Step 1 for the channels other than default. Also look at the ~/SAVE.condarc file if you made one in Step 2.
# If you see defaults it needs to be removed with conda config –remove channel defaults as this is the channel that requires the license (as well as any channel with anaconda in its name)

# Add any other channels you need as in this example

# conda config --add channels bioconda

# Look at your ~/SAVE.condarc and enviroment YAML files created above for the extra channels you used in the past.

# At this point make an archive backup of your new miniforge install so you can just extract it to start from the beginning easily without having to go through the install and long download times again.  
# From the directory where you installed it do

tar czf miniforge3.tar.gz miniforge3

# assuming you left it the default name of miniforge3.  Then if you need to start over because of package install failures in the next step you do so with

#    rm -rf miniforge3
#    tar xzf miniforge3.tar.gz

# First active the new miniforge3 install in your shell environment with

eval "$(/path/to/miniforge3/bin/conda shell.bash hook)"

# where you need to use YOUR path where you installed it and change bash to tcsh shell if you use tcsh instead

# After downloading and installing miniforge, it is worth giving it a try. Once the YML file is edited properly try creating a test environment with it first by running: 

conda env create --name test_base --file=test_environment.yml

# If that works and you want it to be your base environment you can try running:

conda env update --file=test_environment.yml


# OPTION 1: If you are fine with just using the latest versions of all packages,  run conda list and compare to base_pkg_list.txt file made above. Install any missing packages with conda install (or just pip if no conda package exists).

# If you want specific versions of certain packages you can do that by appending “=version” to the package name. For example:

# conda install tensorflow=2.2.0

# If you have a lot of these, create a text file with the pkg=version one line at a time and then run

# conda install --file=pkglist.txt
 
# Repeat these steps for any sub-environments you want after creating and then activating them.

# OPTION 2: If you want to try to recover the exact same python and package versions you had in your Anaconda install then we will use the YML file we exported in Step 1.  
# However, you need to edit this file to remove default and any other anaconda channels at the top. Then (very tediously) remove build strings from all the conda package lines. For example where you see a package line like

#     - bcrypt=3.1.6=py37h7b6447c_0

# you need to remove the 2nd equal sign and everything after it so the line is just

#      - bcrypt=3.1.6
# sed 's/=[^=]*//2g' base_environment.yml

# FYI, these build strings are unique to each channel so you cannot reinstall the same build from another channel which is why you must remove them.

# Also look at the package list for any ‘anaconda’ packages like ‘anaconda-navigator’ and remove the lines entirely from the YML file.

# Ultimately if the YML procedure does not work, you may need to resort to Option 1 above and do groups of about 10 packages at a time in a pkglist.txt file using conda install –file=pkglist.txt 
# to try to recreate your old distribution manually step by step.  And you probably will not be able to get every single package at the same version as you had previously.  
# Concentrate on the versions of the primary package(s) you Python scripts are built around like tensorflow or numpy.

# But it is worth giving it a try. Once the YML file is edited properly try creating a test environment with it first by running

#     conda env create --name test_base --file=base_environment.yml

# If that works and you want it to be your base environment you can try running

#     conda env update --file=base_environment.yml

# but this could fail even though the sub-enviroment worked due to old packages being incompatible with things required in the base environment.

# After you are done with the base environment, then for each sub-environment you have a *.yml file you can recreate each with

#     conda env create --name myenvname --file=myenv_environment.yml

# Obviously change the myenvname and yml file name as needed.


