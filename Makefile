PI=192.168.1.76

all: cal.svg cal.png

cal.svg: cal.svg.erb
	@rm -f cal.svg
	erb < cal.svg.erb > cal.svg

cal.png: cal.svg
	@rm -f cal.png
	convert -rotate 270 cal.svg cal.png

clean:
	$(RM) cal.svg cal.png

upload: cal.png
	scp cal.png $(PI):
	ssh $(PI) sudo ruby src/piink/test.rb cal.png

