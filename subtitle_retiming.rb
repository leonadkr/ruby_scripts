#!/usr/bin/ruby -Ku

# a program for retiming a subtitle file in .ssa, .ass, .srt or .idx  format
#
# four arguments for input:
#  first argument is a subtitle file
#  second argument is the first line in the file to retime
#  third argument is the last line in the file to retime
#  fourth argument is a time delay in seconds
#
# the input file is overwriting by the retimed subtitle


require 'fileutils'
require 'tempfile'


def seconds_to_hms( secs )
	h = ( secs / 3600.0 ).to_i
	m = ( ( secs - 3600.0 * h ) / 60.0 ).to_i
	s = secs - 3600.0 * h - 60.0 * m

	[h, m, s]
end


temp_dir = Dir.mktmpdir( File.basename( $0 ) )

file_name = ARGV[0]
temp_file = Tempfile.new( file_name, temp_dir )

start_line = ARGV[1].to_i
stop_line = ARGV[2].to_i
delay = ARGV[3].to_f

sub_file = File.open( file_name, "r" )
sub_file.each_line{ |line|
	if ( start_line .. stop_line ).include?( sub_file.lineno )
		line.gsub!( /(\d):([0-5]\d):([0-5]\d\.\d\d)/ ){
			secs = 3600.0 * $1.to_f + 60.0 * $2.to_f + $3.to_f + delay
			hms = seconds_to_hms( secs )
			sprintf( "%d:%02d:%05.2f", hms[0], hms[1], hms[2] )
		}
		line.gsub!( /(\d\d):([0-5]\d):([0-5]\d\,\d\d\d)/ ){
			secs = 3600.0 * $1.to_f + 60.0 * $2.to_f + $3.sub( ",", "." ).to_f + delay
			hms = seconds_to_hms( secs )
			sprintf( "%02d:%02d:%06.3f", hms[0], hms[1], hms[2] ).sub(".",",")
		}
		line.gsub!( /(\d\d):([0-5]\d):([0-5]\d\:\d\d\d)/ ){
			secs = 3600.0 * $1.to_f + 60.0 * $2.to_f + $3.sub( ":", "." ).to_f + delay
			hms = seconds_to_hms( secs )
			sprintf( "%02d:%02d:%06.3f", hms[0], hms[1], hms[2] ).sub( ".", ":" )
		}
	end

	temp_file.puts( line )
}

sub_file.close
temp_file.close
FileUtils.cp( temp_file.path, file_name )

temp_file.unlink
Dir.unlink( temp_dir )
