#!/bin/sh

PIDFILE="/run/messagebus.pid"
LOCKFILE="/var/lock/subsys/dbus-daemon"

RET_VAL=0

START() {
	printf "Starting system message bus: "

	dbus-uuidgen --ensure
	if dbus-daemon --system; then
		echo "done"
		touch "$LOCKFILE"
		RET_VAL=0
	else
		echo "failed"
		RET_VAL=1
	fi
}

STOP() {
	printf "Stopping system message bus: "

	if [ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null; then
		echo "done"
		rm -f "$PIDFILE" "$LOCKFILE"
		RET_VAL=0
	else
		echo "failed"
		RET_VAL=1
	fi
}

mkdir -p "/run/dbus" "/var/lock/subsys" "/tmp/dbus"

case "$1" in
	start) START ;;
	stop) STOP ;;
	restart)
		STOP
		START
		;;
	condrestart)
		[ -f "$LOCKFILE" ] && {
			STOP
			START
		}
		;;
	reload)
		echo "Message bus can't reload its configuration, you have to restart it"
		RET_VAL=1
		;;
	*)
		echo "Usage: $0 {start|stop|restart|condrestart|reload}"
		RET_VAL=1
		;;
esac

exit "$RET_VAL"
