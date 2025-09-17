---
layout: post
title: The Adventure of Mr. SOC II
date: 2015-10-20 14:17
lang: en
permalink: /en/articles/2015-10/the-adventure-of-mr-soc-ii/
categories: [Cyber Security, Forensics, Incident Investigation, Fiction]
---
In our previous post, we examined the secret data exchange between Ann Dercover and the suspect friend. During that investigation, Ann managed to disappear. But even before vanishing, records of her most recent network activities had been kept.<!--more-->

These relevant logs were once again delivered to our protagonist Mr. SOC. He felt a surge of happiness. With each case and analysis he felt closer to Ann. Although they had never actually met, via every analysis he was obtaining more information about her life.

Mr. SOC first wanted to list the IP addresses making the most noise in the new pcap file.

{% highlight bash %}
[arq@darkarq puzzle 2]$ tcpdump -tnr evidence02.pcap | awk -F '-' '{print $1.$2.$3.$4}'|sort|uniq -c |sort -n |tail
reading from file evidence02.pcap, link-type EN10MB (Ethernet)
4 ARP, Reply 192.168.1.10 isat 00:0c:29:9b:ee:14, length 28
4 IP 192.168.1.10.123 &gt; 192.168.1.255.123: NTPv4, Broadcast, length 48
4 IP 192.168.1.10.52111 &gt; 192.168.1.30.514: SYSLOG kernel.warning, length: 188
4 IP 192.168.1.10.52111 &gt; 192.168.1.30.514: SYSLOG kernel.warning, length: 194
4 IP 192.168.1.10.52111 &gt; 192.168.1.30.514: SYSLOG kernel.warning, length: 238
4 IP 192.168.1.159.138 &gt; 192.168.1.255.138: NBT UDP PACKET(138)
7 ARP, Request whohas 192.168.1.30 tell 192.168.1.10, length 28
8 ARP, Reply 192.168.1.30 isat 00:0c:29:c0:89:a6, length 28
12 IP 192.168.1.10.52111 &gt; 192.168.1.30.514: SYSLOG kernel.warning, length: 236
12 IP 192.168.1.159.137 &gt; 192.168.1.255.137: NBT UDP PACKET(137): QUERY; REQUEST; BROADCAST
{% endhighlight %}


To get a more summarized view, he decided to use the tool Argus, converting the pcap into an argus file (a .ra file).

{% highlight bash %}
[arq@darkarq puzzle 2]$ sudo argus -r evidence02.pcap -w evidence02.ra
[arq@darkarq puzzle 2]$ rahosts -r evidence02.ra 
192.168.1.2: (1) 192.168.1.159
192.168.1.10: (3) 192.168.1.30, 192.168.1.159, 192.168.1.255
192.168.1.30: (1) 192.168.1.10
192.168.1.159: (5) 10.1.1.20, 64.12.102.142, 192.168.1.10, 192.168.1.30, 192.168.1.255
{% endhighlight %}

Among the listed IPs, the external address 64.12.102.142 immediately caught his eye. To understand what this IP was, he ran a whois lookup.

{% highlight bash %}
[arq@darkarq puzzle 2]$ whois -h whois.cymru.com 64.12.102.142
AS | IP | AS Name
1668 | 64.12.102.142 | AOL-ATDN - AOL Transit Data Network,US
{% endhighlight %}

It turned out to correspond to an IM protocol server. Of course, SOME could have obtained the IP for the IM protocol through listing the destination IPs communicated with before converting to an argus file—but then he would have skipped using Argus. SOME made a point of using different tools in every investigation to keep his skills sharp.

{% highlight bash %}
[arq@darkarq puzzle 2]$ tcpdump -nn -r evidence02.pcap | grep IP | awk -F '&gt;' '{print $2}' | awk '{print $1}' | sort -nu
reading from file evidence02.pcap, link-type EN10MB (Ethernet)
10.1.1.20.53:
64.12.102.142.587:
192.168.1.30.514:
{% endhighlight %}

Mr. SOC quickly recognized that the communication with 10.1.1.20 was DNS-related, so that IP was excluded from the investigation.

Still wanting to keep a big-picture view and to understand more about what was happening, he decided to see the volumes of all communications.

{% highlight bash %}
arq@darkarq puzzle 2]$ racluster -M norep -m saddr daddr -nr evidence02.ra -w - | rasort -L0 -m bytes -s saddr daddr pkts bytes
SrcAddr DstAddr TotPkts TotBytes 
192.168.1.159 64.12.102.142 490 314771
192.168.1.10 192.168.1.30 24 6320
192.168.1.159 192.168.1.255 16 2007
192.168.1.10 192.168.1.30 14 588
192.168.1.159 192.168.1.30 2 519
192.168.1.159 10.1.1.20 2 371
192.168.1.10 192.168.1.255 4 360
192.168.1.30 192.168.1.10 4 360
192.168.1.10 192.168.1.159 4 168
192.168.1.30 192.168.1.10 4 168
192.168.1.159 192.168.1.10 4 168
192.168.1.2 192.168.1.159 2 84
192.168.1.159 192.168.1.30 2 84
{% endhighlight %}

From this table, Mr. SOC recognized that most of the packets (and bytes) were coming from IP 192.168.1.159. To narrow the investigation, he decided to follow the flows involving that IP.

{% highlight bash %}
[arq@darkarq puzzle 2]$ tcpflow -r evidence02.pcap 
[arq@darkarq puzzle 2]$ ls
064.012.102.142.00587-192.168.001.159.01036 192.168.001.159.01036-064.012.102.142.00587
064.012.102.142.00587-192.168.001.159.01038 192.168.001.159.01038-064.012.102.142.00587
{% endhighlight %}

{% highlight bash %}
[arq@darkarq puzzle 2]$ ls -lhS
total 644K

-rw-r--r-- 1 arq users 280K 10.10.2009 16:38 192.168.001.159.01038-064.012.102.142.00587
-rw-r--r-- 1 arq users 1.5K 10.10.2009 16:35 192.168.001.159.01036-064.012.102.142.00587
-rw-r--r-- 1 arq users 507 10.10.2009 16:35 064.012.102.142.00587-192.168.001.159.01036
-rw-r--r-- 1 arq users 507 10.10.2009 16:38 064.012.102.142.00587-192.168.001.159.01038
{% endhighlight %}

This output confirmed that a large volume of data was indeed exchanged between that external IP and the internal machine at 192.168.1.159. Next, Mr.SOC wondered about protocol usage: which protocols had been used inside the traffic file and how those bytes were distributed.

{% highlight bash %}
[arq@darkarq puzzle 2]$ tshark -r evidence02.pcap -zio,phs
===================================================================
Protocol Hierarchy Statistics
Filter:

eth frames:572 bytes:325968
ip frames:542 bytes:324708
udp frames:52 bytes:9937
syslog frames:26 bytes:6839
ntp frames:8 bytes:720
nbdgm frames:4 bytes:903
smb frames:4 bytes:903
mailslot frames:4 bytes:903
browser frames:4 bytes:903
nbns frames:12 bytes:1104
dns frames:2 bytes:371
tcp frames:490 bytes:314771
smtp frames:247 bytes:301625
imf frames:2 bytes:1376
arp frames:30 bytes:1260
===================================================================
{% endhighlight %}


Among the used protocols, the SMTP protocol stood out particularly. SOME decided to focus his analysis on SMTP traffic.

First, for the IP 64.12.102.142, SOME checked the reverse DNS records to see if it belonged to an SMTP server.

{% highlight bash %}
[arq@darkarq puzzle 2]$ dig -x 64.12.102.142

; &lt;&lt;&gt;&gt; DiG 9.9.2-P2 &lt;&lt;&gt;&gt; -x 64.12.102.142
;; global options: +cmd
;; Got answer:
;; -&gt;&gt;HEADER&lt;&lt;- opcode: QUERY, status: NOERROR, id: 14845
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 4, ADDITIONAL: 5

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;142.102.12.64.in-addr.arpa. IN PTR

;; ANSWER SECTION:
142.102.12.64.in-addr.arpa. 3600 IN PTR smtp-mc.mx.aol.com.

;; AUTHORITY SECTION:
12.64.in-addr.arpa. 981 IN NS dns-02.ns.aol.com.
12.64.in-addr.arpa. 981 IN NS dns-07.ns.aol.com.
12.64.in-addr.arpa. 981 IN NS dns-06.ns.aol.com.
12.64.in-addr.arpa. 981 IN NS dns-01.ns.aol.com.

;; ADDITIONAL SECTION:
dns-01.ns.aol.com. 981 IN A 64.12.51.132
dns-02.ns.aol.com. 981 IN A 205.188.157.232
dns-06.ns.aol.com. 127893 IN A 207.200.73.80
dns-07.ns.aol.com. 981 IN A 64.236.1.107

;; Query time: 47 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Fri Mar 27 08:20:27 2015
;; MSG SIZE rcvd: 238
{% endhighlight %}


The reverse lookup revealed that the IP is affiliated with AOL’s SMTP server. At this point it became clear that email traffic had taken place.

Mr.SOC first followed the flow with the greatest data transfer.

{% highlight bash %}
[arq@darkarq puzzle 2]$ xxd 192.168.001.159.01038-064.012.102.142.00587 | head -n 12
00000000: 4548 4c4f 2061 6e6e 6c61 7074 6f70 0d0a EHLO annlaptop..
00000010: 4155 5448 204c 4f47 494e 0d0a 6332 356c AUTH LOGIN..c25l
00000020: 5957 7435 5a7a 4d7a 6130 4268 6232 7775 YWt5ZzMza0Bhb2wu
00000030: 5932 3974 0d0a 4e54 5534 636a 4177 6248 Y29t..NTU4cjAwbH
00000040: 6f3d 0d0a 4d41 494c 2046 524f 4d3a 203c o=..MAIL FROM: &lt;
00000050: 736e 6561 6b79 6733 336b 4061 6f6c 2e63 sneakyg33k@aol.c
00000060: 6f6d 3e0d 0a52 4350 5420 544f 3a20 3c6d om&gt;..RCPT TO: &lt;m
00000070: 6973 7465 7273 6563 7265 7478 4061 6f6c istersecretx@aol
00000080: 2e63 6f6d 3e0d 0a44 4154 410d 0a4d 6573 .com&gt;..DATA..Mes
00000090: 7361 6765 2d49 443a 203c 3030 3131 3031 sage-ID: &lt;001101
000000a0: 6361 3439 6165 2465 3933 6534 3562 3024 ca49ae$e93e45b0$
000000b0: 3966 3031 6138 6330 4061 6e6e 6c61 7074 9f01a8c0@annlapt
{% endhighlight %}

To make it more meaningful, he converted it into a human-readable form via string search.


{% highlight bash %}
[arq@darkarq puzzle 2]$ strings 192.168.001.159.01038-064.012.102.142.00587 | head -n 20
EHLO annlaptop
AUTH LOGIN
c25lYWt5ZzMza0Bhb2wuY29t
NTU4cjAwbHo=
MAIL FROM: &lt;sneakyg33k@aol.com&gt;
RCPT TO: &lt;mistersecretx@aol.com&gt;
DATA
Message-ID: &lt;001101ca49ae$e93e45b0$9f01a8c0@annlaptop&gt;
From: "Ann Dercover" &lt;sneakyg33k@aol.com&gt;
To: &lt;mistersecretx@aol.com&gt;
Subject: rendezvous
Date: Sat, 10 Oct 2009 07:38:10 -0600
MIME-Version: 1.0
Content-Type: multipart/mixed;
boundary="----=_NextPart_000_000D_01CA497C.9DEC1E70"
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2900.2180
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2900.2180
This is a multi-part message in MIME format.
{% endhighlight %}

From the first 20 lines, he determined the login had happened using the Base64-encoded strings:

{% highlight bash %}
c25lYWt5ZzMza0Bhb2wuY29t
NTU4cjAwbHo=
{% endhighlight %}

And that the email sneakyg33k@aol.com belonged to Ann, sending to mistersecretx@aol.com. Ann’s laptop was identified as annlaptop.

MR.SOC, knowing that in SMTP the login credentials are moved between AUTH LOGIN and DATA, performed Base64 decoding:

{% highlight bash %}
[arq@darkarq puzzle 2]$ echo 'c25lYWt5ZzMza0Bhb2wuY29t' | base64 -d -
sneakyg33k@aol.com

[arq@darkarq puzzle 2]$ echo 'NTU4cjAwbHo=' | base64 -d -
558r00lz
{% endhighlight %}

Good news for Mr.SOC. Now he had discovered Ann’s username and password. At this point he, restraining his excitement, continued investigating because he wanted to see the mail-traffic contents.

{% highlight bash %}
[arq@darkarq puzzle 2]$ strings 192.168.001.159.01038-064.012.102.142.00587 | more 
EHLO annlaptop
AUTH LOGIN
c25lYWt5ZzMza0Bhb2wuY29t
NTU4cjAwbHo=
MAIL FROM: &lt;sneakyg33k@aol.com&gt;
RCPT TO: &lt;mistersecretx@aol.com&gt;
DATA
Message-ID: &lt;001101ca49ae$e93e45b0$9f01a8c0@annlaptop&gt;
From: "Ann Dercover" &lt;sneakyg33k@aol.com&gt;
To: &lt;mistersecretx@aol.com&gt;
Subject: rendezvous
Date: Sat, 10 Oct 2009 07:38:10 -0600
MIME-Version: 1.0
Content-Type: multipart/mixed;
boundary="----=_NextPart_000_000D_01CA497C.9DEC1E70"
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2900.2180
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2900.2180
This is a multi-part message in MIME format.
------=_NextPart_000_000D_01CA497C.9DEC1E70
Content-Type: multipart/alternative;
boundary="----=_NextPart_001_000E_01CA497C.9DEC1E70"
------=_NextPart_001_000E_01CA497C.9DEC1E70
Content-Type: text/plain;
charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Hi sweetheart! Bring your fake passport and a bathing suit. Address =
attached. love, Ann
------=_NextPart_001_000E_01CA497C.9DEC1E70
Content-Type: text/html;
charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"&gt;
&lt;HTML&gt;&lt;HEAD&gt;
&lt;META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1"&gt;
&lt;META content=3D"MSHTML 6.00.2900.2853" name=3DGENERATOR&gt;
&lt;STYLE&gt;&lt;/STYLE&gt;
&lt;/HEAD&gt;
&lt;BODY bgColor=3D#ffffff&gt;
&lt;DIV&gt;&lt;FONT face=3DArial size=3D2&gt;Hi sweetheart! Bring your fake passport =
and a=20
bathing suit. Address attached. love, Ann&lt;/FONT&gt;&lt;/DIV&gt;&lt;/BODY&gt;&lt;/HTML&gt;
------=_NextPart_001_000E_01CA497C.9DEC1E70--
------=_NextPart_000_000D_01CA497C.9DEC1E70
Content-Type: application/octet-stream;
name="secretrendezvous.docx"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
filename="secretrendezvous.docx"
UEsDBBQABgAIAAAAIQDleUAGfwEAANcFAAATAAgCW0NvbnRlbnRfVHlwZXNdLnhtbCCiBAIooAAC
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC0
VMluwjAQvVfqP0S+VsTQQ1VVBA5dji1S6QcYexKsepNttr/vOEBEKQSpwCVSPH7LPI/dHy61yubg
g7SmIL28SzIw3AppqoJ8jd86jyQLkRnBlDVQkBUEMhzc3vTHKwchQ7QJBZnG6J4oDXwKmoXcOjBY
Ka3XLOKvr6hj/JtVQO+73QfKrYlgYicmDjLov0DJZipmr0tcXjtxpiLZ83pfkiqI1Amf1ulBhAcV
9iDMOSU5i9gbnRux56uz8ZQjst4TptKFOzR+RCFVfnvaFdjgPjBMLwVkI+bjO9PonC6sF1RYPtPY
.....
{% endhighlight %}

He saw that the email content included a message:

“Hi sweetheart! Bring your fake passport and a bathing suit. Address attached. love, Ann”

And that there was an attachment named secretrendezvous.docx, encoded in Base64.

Mr. SOC’s hope about Ann darkened in that moment. Because in the email content, she was inviting her lover via an address in the attachment, presumably gathering together money earned from illegal activities.

Putting aside his momentary shock, Mr. SOC, believing that every drum has its mallet and every apple its core, decided he must find out where Ann was going. To do that, he needed to seize that sent file. The file is named secretrendezvous.docx. But the file must be recomposed from the pcap.

{% highlight bash %}
[arq@darkarq puzzle 2]$ cat 192.168.001.159.01038-064.012.102.142.00587 | head -n 3700 | tail -n 3640 | tr -d "\r\n" &gt; evidence.encoded
[arq@darkarq puzzle 2]$ base64 -d evidence.encoded &gt; evidence.docx
[arq@darkarq puzzle 2]$ unzip -q evidence.docx
{% endhighlight %}

After reassembling the attachment and unzipping, Mr. SOC discovered that in the path word/media/1.png the relevant map appeared. Ann was planning to escape to Mexico with her secret lover. he wondered, even if he wasn’t in Mexico, where people would flee. He thought about Once Upon a Time in Mexico and felt good emotions about Mexico. He thought it might be nice to hang out with Ann on Mexican beaches.

MR. SOC could have also seen the address directly by opening the docx file. But he remained faithful to the command line.

By the way, the task could have been done much more quickly using a tool called NetworkMiner. But the purpose again was to get to know different tools better and stay loyal to the command line.

See you in the next installment of the story.


