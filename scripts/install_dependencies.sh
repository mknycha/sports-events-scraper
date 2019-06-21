#!/bin/bash

yum update -y
yum install ruby24 -y
alternatives --set ruby /usr/bin/ruby2.4
bundle install