#xgraph tcp0.xg tcp6.xg tcp1.xg
set ns [new Simulator]

set tracefile [open tahoe.tr w]
$ns trace-all $tracefile
set namfile [open tahoe.nam w] 
$ns namtrace-all $namfile

set f0 [open "tcp0.xg" w]
set f6 [open "tcp6.xg" w]
set f1 [open "tcp1.xg" w]

proc finish {} {
	global ns tracefile namfile
	global f0 f6 f1
	$ns flush-trace
	close $tracefile
	close $namfile
	close $f0
	close $f6
	close $f1
	exec nam tahoe.nam &
	#exec xgraph tcp0.xg tcp6.xg tcp1.xg & #geometry-800*600 &
	exit
}

proc plotWindow {} {
global ns tcp0 tcp6 tcp1 f0 f6 f1
set now [$ns now]
set cwnd1 [$tcp0 set cwnd_]
set cwnd2 [$tcp6 set cwnd_]
set cwnd3 [$tcp1 set cwnd_]
puts $f0 "$now $cwnd1"
puts $f6 "$now $cwnd2"
puts $f1 "$now $cwnd3"
$ns at [expr $now+0.01] "plotWindow"
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 3Mb 10ms DropTail
$ns duplex-link $n6 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n5 2Mb 10ms DropTail
$ns duplex-link $n3 $n7 2Mb 10ms DropTail
$ns duplex-link $n3 $n4 2Mb 10ms DropTail

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n6 $n2 orient right
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n3 $n5 orient right-up
$ns duplex-link-op $n3 $n7 orient right
$ns duplex-link-op $n3 $n4 orient right-down

set tcp0 [new Agent/TCP]
set sink5 [new Agent/TCPSink]
$ns attach-agent $n0 $tcp0
$ns attach-agent $n5 $sink5
$ns connect $tcp0 $sink5
$tcp0 set class_ 1
$ns color 1 Red

set tcp6 [new Agent/TCP]
set sink7 [new Agent/TCPSink]
$ns attach-agent $n6 $tcp6
$ns attach-agent $n7 $sink7
$ns connect $tcp6 $sink7
$tcp6 set class_ 2
$ns color 2 Blue

set tcp1 [new Agent/TCP]
set sink4 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n4 $sink4
$ns connect $tcp1 $sink4
$tcp1 set class_ 3
$ns color 3 Yellow

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP
$ftp0 set packetSize_ 500
$ftp0 set interval_ 0.01

set ftp6 [new Application/FTP]
$ftp6 attach-agent $tcp6
$ftp6 set type_ FTP
$ftp6 set packetSize_ 500
$ftp6 set interval_ 0.01

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
$ftp1 set packetSize_ 500
$ftp1 set interval_ 0.01


$ns at 0.1 "plotWindow"
$ns at 0.5 "$ftp0 start"
$ns at 3.5 "$ftp0 stop"

$ns at 1.4 "$ftp6 start"
$ns at 4.1 "$ftp6 stop"

$ns at 1.9 "$ftp1 start"
$ns at 4.4 "$ftp1 stop"

$ns at 5.0 "finish"

$ns run
