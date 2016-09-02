#!/usr/bin/perl -w

# Runner daemon script for the live PSIPRED server.
# This script is run @reboot (see 'rails' user's crontab) and it starts a
# parent process that continuously checks whether the Rails runner is up - if
# not, it spawns a child process with the runner.
# The check happens every 3 minutes, so in order to restart the runner simply
# kill the corresponding process (the one in the 'exec' command below) and a
# new one will be restarted automatically within 3 minutes.

use strict;

$| = 1; # Autoflush - useful if you'll redirect the output.

while (1)
{
    my $output = `ps -elf | grep runner`;
    print "$output\n";
    
    if ($output =~ /-e production Job.poll_all_loop/)
    {
        print "PARENT:: Everything is up and running!\n\n";
    }
    else
    {
        defined(my $kid = fork()) or die "\n\tCannot fork: $!\n\n";
        
        if ($kid)
        {
            print "PARENT:: Successful fork - continuing the 'while' loop. Child at: $kid\n\n";
        }
        else
        {
            sleep 1;
            print "CHILD:: Started running: /usr/local/bin/ruby /home/rails/NewPred3/script/rails runner -e production Job.poll_all_loop\n\n";
            exec("/usr/local/bin/ruby /home/rails/NewPred3/script/rails runner -e production Job.poll_all_loop");
        }
    }
    
    sleep 180;
}

