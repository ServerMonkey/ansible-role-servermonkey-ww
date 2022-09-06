# ansible-role-servermonkey-ww

A collection of generic Ansible tasks and tools.  

## Installation

Recommended Debian package: wildwest  
Alternatively you can use plain Ansible but need to define some variables at runtime.

## Usage

Tasks and scripts are sorted in different groups. Each prefix represents a group.

* **cfg_** = System configurations, usually when you first setup a new system
* **demo_** = Example scripts, use as development reference
* **do_** = Everyday generic system administration tools
* **info_** = Just collect information about a system, no active administration
* **install_** = Install software or groups of software
* **setup_** = Complete system setups, combination of install_ and cfg_

Before running any lager tasks, like **install_** or **setup_** , you need to run **info_test** first to update Ansible facts.
