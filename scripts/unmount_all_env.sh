#!/bin/bash
cat /proc/mounts| grep envs| awk '{ print $2 }'|xargs -I{} umount {}
