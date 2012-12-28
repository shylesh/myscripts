all:
	chmod 755 qeCoreAlert.sh
	chmod 755 src/qeCoreAlert.c
	rm -f /usr/local/bin/qeCoreAlert.sh
	cp ./qeCoreAlert.sh /usr/local/bin/.
	./qeCoreAlert.sh
	rm -f /usr/local/bin/qeCoreAlert
	gcc -o /usr/local/bin/qeCoreAlert ./src/qeCoreAlert.c
	chmod 755 /usr/local/bin/qeCoreAlert

