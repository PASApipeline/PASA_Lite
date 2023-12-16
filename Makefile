
all: 
	if [ ! -d bin ]; then mkdir bin; fi
	cd pasa-plugins/pasa_cpp && $(MAKE) && cp pasa ../../bin/.
	cd pasa-plugins/slclust && $(MAKE) && cp slclust ../../bin/.

clean:
	cd pasa-plugins/pasa_cpp && $(MAKE) clean
	cd pasa-plugins/slclust && $(MAKE) clean
	rm -f bin/* 

###################################################################


