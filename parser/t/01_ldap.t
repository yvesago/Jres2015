# t/001_ldap.t - check ldap log 

use Test::More tests => 6;

BEGIN { use_ok( 'MyLdapLog' ); }

my $t1 = <<E1;
Feb 23 20:43:14 l1 slapd[9353]: conn=1 fd=57 ACCEPT from IP=192.10.7.45:35358 (IP=0.0.0.0:389)
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=0 BIND dn="" method=128
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=0 RESULT tag=97 err=0 text=
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=1 SRCH base="dc=univ,dc=fr" scope=0 deref=0 filter="(objectClass=*)"
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=1 SRCH attr=contextCSN
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=1 SEARCH RESULT tag=101 err=0 nentries=1 text=
Feb 23 20:43:14 l1 slapd[9353]: conn=1 op=2 UNBIND
Feb 23 20:43:14 l1 slapd[9353]: conn=1 fd=57 closed
Feb 23 21:17:22 l1 slapd[9353]: conn=2 fd=57 ACCEPT from IP=192.16.64.154:33548 (IP=0.0.0.0:636)
Feb 23 21:17:22 l1 slapd[9353]: conn=2 fd=57 TLS established tls_ssf=128 ssf=128
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=0 BIND dn="cn=add,dc=sys" method=128
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=0 BIND dn="cn=add,dc=sys" mech=SIMPLE ssf=0
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=0 RESULT tag=97 err=0 text=
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=1 MOD dn="uid=aaa1,ou=p,dc=univ,dc=fr"
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=1 MOD attr=supannCodeIne
Feb 23 21:17:22 l1 slapd[9353]: conn=2 op=1 RESULT tag=103 err=0 text=
Feb 23 21:18:22 l1 slapd[9353]: conn=2 op=2 UNBIND
Feb 23 21:18:22 l1 slapd[9353]: conn=2 fd=57 closed
Feb 24 09:23:03 l1 slapd[9353]: conn=4 fd=57 closed (TLS negotiation failure)
Feb 24 09:23:03 l1 slapd[9353]: conn=-1 fd=57 ACCEPT from IP=192.30.10.15:42355 (IP=0.0.0.0:636)
Feb 24 17:30:56 l1 slapd[9353]: conn=5 fd=57 ACCEPT from IP=192.14.218.66:40918 (IP=0.0.0.0:636)
Feb 24 17:30:56 l1 slapd[9353]: conn=5 fd=57 TLS established tls_ssf=128 ssf=128
Feb 24 17:30:56 l1 slapd[9353]: conn=5 op=0 BIND dn="uid=xxx2,ou=p,dc=univ,dc=fr" method=128
Feb 24 17:30:56 l1 slapd[9353]: conn=5 op=0 RESULT tag=97 err=49 text=
Feb 24 17:30:56 l1 slapd[9353]: conn=5 fd=57 closed (connection lost)
E1

my $r1 = <<R1;
c=1;2015-02-23 20:43:14 CET;192.10.7.45;0;;dc=univ,dc=fr;SRCH;(objectClass=*);;contextCSN;1;;
c=2;2015-02-23 21:18:22 CET;192.16.64.154;60;cn=add,dc=sys;;MOD;;uid=aaa1,ou=p,dc=univ,dc=fr;supannCodeIne;;;
c=4;2015-02-24 09:23:03 CET;192.30.10.15;0;;;ERR;;;;;;(TLS negotiation failure)
c=5;2015-02-24 17:30:56 CET;192.14.218.66;0;uid=xxx2,ou=p,dc=univ,dc=fr;;ERR;;;;;e=49;(connection lost)
R1

my @res1 = split "\n",$r1;

my $p = MyLdapLog->new;

my $i = 0;
foreach my $l (split "\n",$t1) {
 my $res = $p->parse($l);
 if ($res) {
   is($res,$res1[$i]);
   $i++;
 }
}

my $t2 =<<E2;
Feb 21 06:30:02 l1 slapd[9353]: conn=7 fd=57 ACCEPT from IP=10.10.226.60:52718 (IP=0.0.0.0:389)
Feb 21 06:30:02 l1 slapd[9353]: conn=7 op=0 BIND dn="cn=monitor,dc=sys" method=128
Feb 21 06:30:02 l1 slapd[9353]: conn=7 op=0 BIND dn="cn=monitor,dc=sys" mech=SIMPLE ssf=0
Feb 21 06:30:02 l1 slapd[9353]: conn=7 op=0 RESULT tag=97 err=0 text=
Feb 21 06:30:02 l1 slapd[9353]: conn=7 op=1 SRCH base="cn=Time,cn=Monitor" scope=2 deref=0 filter="(cn=start)"
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 op=6 SEARCH RESULT tag=101 err=0 nentries=1 text=
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 op=7 SRCH base="cn=Statistics,cn=Monitor" scope=2 deref=0 filter="(cn=bytes)"
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 op=7 SRCH attr=monitorCounter
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 op=7 SEARCH RESULT tag=101 err=0 nentries=1 text=
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 op=8 UNBIND
Feb 21 06:30:02 ldap1m slapd[9353]: conn=7 fd=57 closed
E2

my $r2 =<<R2;
c=7;2015-02-21 06:30:02 CET;10.10.226.60;0;cn=monitor,dc=sys;cn=Time,cn=Monitor;SRCH;(cn=start);;;1;;
c=7;2015-02-21 06:30:02 CET;10.10.226.60;0;cn=monitor,dc=sys;cn=Statistics,cn=Monitor;SRCH;(cn=bytes);;monitorCounter;1;;
R2

my @res2 = split "\n",$r2;
foreach my $l (split "\n",$t2) {
 my $res = $p->parse($l);
 if ($res) {
   is($res."\n",$r2,'ok multi op in same session');
 }

}
