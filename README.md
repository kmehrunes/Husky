# Husky
Husky is a good deployment boy, he doesn't know much but he'll do what you want him to do, but you have to tell him what to do. His job is to make deploying applications easier without the need to set up some fancy stuff.

### Installation
You can install Husky using the installation provided installation script, it'll prompt you to either install it only for the current user or for all users. Then it'll ask for an installation directory (if you chose to install for current user only then the default will be ~/.local/bin, otherwise /usr/bin). **Make sure that you installed it to a directory in your PATH**.

### Usage
#### 1. Initialization
After installing Husky, you can set up the current directory by running the following command:
```
husky init
```

This will prompt you to enter some information such as where your build is and where to deploy it. Upon success, you should have two files: *husky.info* and *husky.build* in the current directory.

#### 2. Build
In order to make Husky build and package your deployable, you have to tell it what to do. In this file you should enter your packaging commands and make sure that their output location matches that of the build directory specified in *husky.info* in the initialization step.

#### 3. Run
Now to run the pipeline of package-deploy-run you need to issue 
```
husky run
```
or
```
husky run <directory 1> <dicretory 2> ...
```
The first variant will execute the pipeline in the current directory and exit, while the second one will execute the pipeline for every directory. Each directory is treated as a different project, therefore each must have its own configuration files.

**Note: Deploying to the remote server uses scp command**

Happy manual automatic deployment :)
