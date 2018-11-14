build_and_install: build install

install:
	vagrant ssh -c 'sudo dpkg -i /vagrant/alternc_3.5.0~rc1_all.deb'

build:
	cd alternc && sbuild -A --no-run-lintian

