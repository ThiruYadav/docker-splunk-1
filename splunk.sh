#!/bin/bash

splunk=/opt/splunk/bin/splunk
exec su splunk -c "exec $(printf '%q ' $splunk "$@")"
