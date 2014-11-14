openflump
=========

OpenFL parser for Flump.   Flump was created at Three Rings by Charlie Groves, Tim Conkling, and Bruno Garcia.
For directions on how to use Flump, visit:
http://threerings.github.io/flump/
Note that this parser makes use of XML only (at the moment), so be sure to export your Flump files using the XML option. 

Quick Example:

	FlumpParser.get().loadPath("assets/format2/FlumpTester/resources.xml");
		var flumpMovie:FlumpMovie = FlumpParser.get().getMovieByName("FlumpTester/Test");
		flumpMovie.play();
