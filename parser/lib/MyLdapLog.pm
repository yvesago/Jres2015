package MyLdapLog;
use Mouse;
use Carp;
use feature 'say';

#use MyLdapLog::Event;

our %Events = ();

my $mem = 0;
my $next = 0;

sub head {
 return "id;time;ip;duration;bind;base;op;filter;on;attr;nbres;errcode;err";
}

sub parse {
   my ($self,$l) = @_;
#   say $l;
   my ($m,$d,$h,$s,$daemon,$con,$fr,$op,@endmsg) = split ' ',$l;
   my $msg = join ' ', @endmsg;

   # manage start session
   my $id = $1 if $con =~ m/conn=([-1\d]+)/;
   if ($id && $id == -1) {
    $id = $mem ; $next = 1;
   };
   return '' if !$id;

   # load or create event
   my $e = (defined $Events{$id}) ? 
      pop @{$Events{$id}} :
      MyLdapLog::Event->new(id => $id);
    
    # print last op in same connection
    $e->time("$m $d $h");
    if ($op =~ m/(SRCH|CMP|ADD|MOD|MODRDN|DEL)/ 
                && $e->op() =~ m/(SRCH|CMP|ADD|MOD|MODRDN|DEL)/
                && $msg =~ m/base=/ ) {
      push @{$Events{$id}}, MyLdapLog::Event->new(
        id => $e->id,
        ip => $e->ip,
        time => $e->time,
        bind => $e->bind,
        base => $e->base,
        op => $e->op,
        filter => $e->filter,
        nbres => $e->nbres,
        errcode => $e->errcode,
        on => $e->on,
        attr => $e->attr)
    };

    # parse
    $e->ip($1) if $msg =~ m/from IP=(.*?):/;
    $e->_timestart("$m $d $h") if $op eq 'ACCEPT';
    $e->bind($1) if $msg =~ m/dn="(.*?)"/ && $op eq 'BIND';
    $e->base($1) if $msg =~ m/base="(.*?)"/ && $op eq 'SRCH';
    $e->op($1) if $op =~ m/(SRCH|CMP|ADD|MOD|MODRDN|DEL)/;
    $e->filter($1) if $msg =~ m/filter="(.*?)"/;
    $e->nbres($1) if $msg =~ m/nentries=(\d+) /;
    $e->errcode($1) if $msg =~ m/err=(\d+) /;
    $e->on($1) if $msg =~ m/dn="(.*?)"/ && ($op eq 'ADD' || $op eq 'MOD' || $op eq 'DEL');
    $e->attr($1) if $msg =~ m/attr=(.*)$/;

   # store event
   push @{$Events{$id}},$e;

   # manage end session
   if ($op =~ m/closed/ || $next) {
#Feb 21 09:23:03 ldap1m slapd[9353]: conn=148850 fd=57 closed (TLS negotiation failure)
#Feb 21 09:23:03 ldap1m slapd[9353]: conn=-1 fd=57 ACCEPT from IP=172.23.10.154:42355 (IP=0.0.0.0:636)
     if ($op =~ m/closed/) {
         my $ds = $e->time;
         $e->close("$m $d $h");
     };
     if ($msg && !$next) {
       $e->err($msg);$e->op('ERR');
     };
     $next = 0;
     if (!$e->ip) { # no ip in event maybe next conn = -1
      $mem = $id;
      #carp '==>'.$id.'<=>'.$l;
      return '';
     };

     my $res = join "\n", map {$_->print } @{$Events{$id}};
     undef $Events{$id};
     return $res;
   };

};



#==============================
package MyLdapLog::Event;
use Mouse;
use DateTime;
use DateTime::Format::Strptime;
use feature 'say';

has 'id' => (is => 'rw', default => 0, isa => 'Int');
has 'time' => (is => 'rw', default => "", isa => 'Str');
has 'ip' => (is => 'rw', default => "", isa => 'Str');
has '_timestart' => (is => 'rw', default => "", isa => 'Str');
has 'duration' => (is => 'rw', default => 0, isa => 'Int');
has 'bind' => (is => 'rw', default => "", isa => 'Str');
has 'base' => (is => 'rw', default => "", isa => 'Str');
has 'op' => (is => 'rw', default => "", isa => 'Str');
has 'filter' => (is => 'rw', default => "", isa => 'Str');
has 'on' => (is => 'rw', default => "", isa => 'Str');
has 'attr' => (is => 'rw', default => "", isa => 'Str');
has 'nbres' => (is => 'rw', default => "", isa => 'Str');
has 'err' => (is => 'rw', default => "", isa => 'Str');
has 'errcode' => (is => 'rw', default => 0, isa => 'Int');

my $format = new DateTime::Format::Strptime(
                pattern => '%Y %b %d %T',
                time_zone => 'Europe/Paris',
		on_error => 'croak',
                );

my $year = DateTime->now->year;

sub close {
  my ($self,$val) = @_;
  return '' if !$self->_timestart || $self->_timestart eq $val;

   my $datestart = $format->parse_datetime($year.' '.$self->_timestart);
   my $dateend = $format->parse_datetime($year.' '.$val);
   $self->duration($dateend->utc_rd_as_seconds() - $datestart->utc_rd_as_seconds());
}

sub print {
  my $self = shift;

  my $date = $format->parse_datetime($year.' '.$self->time)->strftime("%F %T %Z");

  return 'c='.$self->id. 
    ';'.$date.
    ';'.$self->ip.
    ';'.$self->duration.
    ';'.$self->bind.
    ';'.$self->base.
    ';'.$self->op.
    ';'.$self->filter.
    ';'.$self->on.
    ';'.$self->attr.
    ';'.$self->nbres.
    (($self->errcode)?';e='.$self->errcode:';').
    ';'.$self->err;
}

1;
