#!/bin/sh
set -e

date +'%F %T' > $(pwd)/service_wake_date.txt

exec "$@"