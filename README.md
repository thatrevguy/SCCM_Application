# sccm_application

####Table of Contents

1. [Overview - What is sccm_application module?](#overview)
2. [Module Description - What does this module do?](#module-description)
    * [Description - What is it thinking?](#description)
3. [Setup - Basics of getting started with sccm_application](#setup)
    * [Beginning with sccm_application - Installation](#beginning-with-sccm_application)
4. [Usage - Classes, defined types, and their parameters available for configuration](#usage)
    * [Classes](#classes)
5. [Implementation - An under-the-hood peek at what this module is doing](#implementation)
    * [Custom Types](#custom-types)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Release Notes - Notes on the most recent updates to the module](#release-notes)

##Overview
This is a module that will ensure SCCM advertised package deployments are installed or not installed.

##Module Description

Sccm_application module manages what SCCM advertised packages get installed or uninstalled. Argument values for both install and uninstall CCM_Application methods:
* IsMachineTarget = true
* EnforcePreference = Immediate
* Priority = Normal
* IsRebootIfNeeded = false

##Setup

###What sccm_application affects:

* Packages that can be managed through Software Center.

###Beginning with sccm_application

```puppet
sccm_application { 'some-package-name-here': 
    ensure => present,
}
```
##Usage

###Classes

####`sccm_application`

**Parameters within `sccm_application`:**

#####`target`
Determines package name type will attempt to ensure absent or present.

#####`ensure`
Determines whether or not target package should be installed or uninstalled.

##Implementation

###Custom Types

#### [`sccm_application`]
Checks if a SCCM package meets set ensure condition.

##Reference

###Classes
####Public Classes
* [`sccm_application`](#classes): Main class of module for managing advertised SCCM packages.

##Limitations

This module is tested on the following platforms:

* Windows Server 2012 R2
* Windows Server 2012
* Windows Server 2008 R2
* Windows Server 2008

##Development
Submit issues or pull requests to [GitHub](https://github.secureserver.net/ECM/SCCM_Application)

##Release-Notes
* 0.0.1 Currently has no logic for 'waiting' or 'failed' evaluation states. Calling type instance will hang indefinitely if a package requires interaction or fails during install.