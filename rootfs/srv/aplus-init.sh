#!/bin/sh -eu

# Start background services/tasks
#start_services
if [ $USE_GITMANAGER = 'true' ]; then
    run_services aplus-lti-services
    /srv/aplus-set-configure-url def/current 'http://gitmanager:8070/default/aplus-json'
else
    # start course updater (will exit when successful)
    run_services aplus-course-update aplus-lti-services
fi
