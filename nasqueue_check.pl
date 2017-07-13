use strict;
use warnings;
use lib "E:/Nimsoft/perllib";
use Nimbus::API;
use Nimbus::PDS;
use Nimbus::CFG;

# Global variables
$SIG{__DIE__} = \&dieHandler;

# Retrieve informations in the cfg!
my $cfg      = Nimbus::CFG->new("test.cfg");
my $STR_Login       = $cfg->{setup}->{login};
my $STR_Password    = $cfg->{setup}->{password}; 
my $BOOL_Debug      = defined $cfg->{setup}->{debug} ? $cfg->{setup}->{debug} : 0;

undef $cfg;
nimLogin("$STR_Login","$STR_Password") if defined $STR_Login && defined $STR_Password;
main(); # execute main !

# dieHandler method
sub dieHandler {
    my ($err) = @_; 
    warn "$err\n";
    exit(1);
}

# Main
sub main {
    my $robotname = nimGetVarStr(NIMV_ROBOTNAME);
    print "robotname => $robotname \n" if $BOOL_Debug;

    my $nasPort;
    {
        my $PDSArg = Nimbus::PDS->new;
        $PDSArg->string('name','nas');
        my ($RC,$full) = nimRequest($robotname,48000,'probe_list',$PDSArg->data);

        dieHandler('Failed to get probe_list, error:: '.nimError2Txt($RC)) if $RC != NIME_OK;
        my $ResHash = Nimbus::PDS->new($full)->asHash();
        $nasPort = $ResHash->{nas}->{port};
    }

    dieHandler('Nas port not found') if !defined $nasPort;
    print "nas port => $nasPort\n" if $BOOL_Debug;
    my $nisQueueLength;
    {
        my $PDSArg = Nimbus::PDS->new;
        $PDSArg->number('detail',1);
        my ($RC,$full) = nimRequest($robotname,$nasPort,'get_info',$PDSArg->data);

        dieHandler('Failed to get nas informations, error:: '.nimError2Txt($RC)) if $RC != NIME_OK;
        my $ResHash = Nimbus::PDS->new($full)->asHash();
        $nisQueueLength = $ResHash->{pub_subscribers}[5]->{queue_len};
    }
}