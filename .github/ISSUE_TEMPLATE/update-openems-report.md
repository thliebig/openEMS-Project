---
name: 'Report update-openEMS.sh Bug'
about: 'Report a bug that affects update-openEMS.sh.'
title: ''
labels: ''
assignees: ''

---

If you're reporting a problem in `update-openEMS.sh`, please attach the full
error log file as plaintext, or upload this file as an attachment. This file is
more important than the on-screen messages.

If an error occurs, its location is printed to the screen:

    build openEMS and dependencies ... please wait
    make failed, build incomplete, please see logfile for more details...
    /home/user/openEMS-Project/build_XXXXXXXX_XXXXXX.log
    build incomplete, cleaning up tmp dir ...

If possible, please also check whether the problem still exists in the latest
`git master` branch.

## Checklist

- [ ] Full logs attached?
- [ ] `git master` still has problem?
