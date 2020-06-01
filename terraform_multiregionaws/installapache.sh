#!/bin/bash
sudo apt-get update 
sudo apt-get install git tree apache2 -y
sudo systemctl enable apache2.service
sudo systemctl start apache2.service
