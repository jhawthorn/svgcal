PI=192.168.1.76

all: cal.svg cal.png

cal.svg: cal.svg.erb events.json
	@rm -f cal.svg
	erb < cal.svg.erb > cal.svg

cal.png: cal.svg
	@rm -f cal.png
	convert -rotate 270 cal.svg cal.png

clean:
	$(RM) cal.svg cal.png

update: update_data.rb
	ruby update_data.rb

upload: cal.png
	scp cal.png $(PI):
	ssh $(PI) sudo ruby src/piink/test.rb cal.png

