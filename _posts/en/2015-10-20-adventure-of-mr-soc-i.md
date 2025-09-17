---
layout: post
title: The Adventure of Mr. SOC I
date: 2015-10-20 14:06
comments: true
lang: en
categories: [Cyber Security, Forensics, Incident Investigation, Fiction]
permalink: /en/articles/2015-10/the-adventure-of-mr-soc-1/
---
Our story actually begins with a woman named Ann Dercover, who is accused of industrial espionage on behalf of a rival firm. There are suspicions that Ann possesses certain confidential information within her company and that she has leaked this information externally. <!--more-->

Because of these suspicions, the network security team has for some time been conducting monitoring activity targeting Ann’s computer and collecting traffic logs. However, until the latest developments, nothing definitive had been discovered. 

Finally, the security team detected an unexpected device entering the wireless network. (The “unexpected device entry” part is a bit illogical, but let’s go with the excitement.) Since ingress and egress to the company are tightly controlled, it is believed that this device connected from a zone (like the parking lot) where wireless signal is reachable. Ann’s IP address is 192.168.1.158, and it was determined that there was certain traffic between her and this unexpected laptop. 

After this brief data exchange, the suspicious device left the network.  ￼

The PCAP file containing Ann’s network activity was sent to our protagonist SOME (it’s just a nickname, by coincidence). The target company had recently heard a lot about SOME on Twitter (a sarcastic laugh). Mr.SOC’s name was everywhere. Even people who don’t carry out systematic long-term strategic work in big structures were going around saying “SOC is this, SOC is that.”  ￼

Our protagonist Mr. SOC felt a bit flattered. The number of followers on Twitter suddenly increased, people were shouting out their name and so on. After thinking a bit, they realized that a law had passed allowing people to use their own names (in some context). So everyone was shouting names. At first Mr. SOC couldn’t make sense of it but then thought about cases where pentests are done for 200 liras, inhaled smoke, laughed, and began investigating. 

As SOME does before every investigation, if there is a name they first check the LinkedIn profile <img class="alignright wp-image-3310" src="http://kogungor.com/wp-content/uploads/2015/03/harley-girl-0c23aec9-2066-4e81-93a1-5be195b24645.jpg" alt="harley-girl-0c23aec9-2066-4e81-93a1-5be195b24645" width="259" height="172" /> to see a picture. Since it was a woman’s name, the imagination alone was pleasant. SOME wanted to embellish the investigation process with nice fantasies and reached Ann’s picture through her LinkedIn account.  

Seeing the picture SOME said, “Let her be a spy then, this woman,” and wanted to see what’s in the PCAP file, who made the most noise in it.
<div id="crayon-562617db5e78c011179526" class="crayon-syntax crayon-theme-solarized-light crayon-font-liberation-mono crayon-os-mac print-yes notranslate" data-settings=" minimize scroll-mouseover"></div>

{% highlight bash %}
arq@darkarq puzzle 1]$ tcpdump -tnr evidence01.pcap | awk -F '.' '{print $1"."$2"."$3"."$4}'|sort|uniq -c |sort -n |tail
reading from file evidence01.pcap, link-type EN10MB (Ethernet)
3 IP 192.168.1.30
4 IP 192.168.1.10
5 IP 64.236.68.246
7 IP 192.168.1.2
20 IP 64.12.24.50
24 IP 64.12.25.91
28 IP 192.168.1.157
31 IP 205.188.13.12
38 IP 192.168.1.158
59 IP 192.168.1.159
{% endhighlight %}

Listing the noisy IP addresses, SOME noticed that besides local network there were also external IPs with communication channels opened. Actually, it was obvious the suspicious connection was via wireless network and that the incident took place in the internal network. But when SOME saw the photo they also wanted to see where this woman hangs out.  ￼

{% highlight bash %}
[arq@darkarq puzzle 1]$ whois -h whois.cymru.com 64.12.24.50
AS | IP | AS Name
1668 | 64.12.24.50 | AOL-ATDN - AOL Transit Data Network,US
{% endhighlight %}

When querying the other IPs, SOME always arrived at the same result. Yes, the woman is chatting. That was a big deal. Since SOME is Turkish, if they found the chat account, they might send her a message like “if you’re alone, shall we meet?” After all, love is one thing, work another.  ￼

To narrow the target surface a bit more, SOME assumed there must be at least one flow among those noisy IPs, and split the PCAP into segments so traffic could be examined as TCP flows. 

{% highlight bash %}
[arq@darkarq puzzle 1]$ tcpflow -r evidence01.pcap
[arq@darkarq puzzle 1]$ ls
064.012.024.050.00443-192.168.001.158.51128 192.168.001.158.51128-064.012.024.050.00443
064.012.025.091.00443-192.168.001.159.01221 192.168.001.159.01221-064.012.025.091.00443
064.236.068.246.00080-192.168.001.159.01273 192.168.001.159.01271-205.188.013.012.00443
192.168.001.002.55488-192.168.001.030.00022 192.168.001.159.01272-192.168.001.158.05190
192.168.001.030.00022-192.168.001.002.55488 192.168.001.159.01273-064.236.068.246.00080
192.168.001.158.05190-192.168.001.159.01272 205.188.013.012.00443-192.168.001.159.01271

{% endhighlight %}

Because SOME is a master of chat, they saw on the flow 192.168.001.158.05190-192.168.001.159.01272 that port 05190 was used. SOME wanted to look more closely. 

{% highlight bash %}
[arq@darkarq puzzle 1]$ xxd 192.168.001.158.05190-192.168.001.159.01272 | more
00000000: 4f46 5432 0100 0101 0000 0000 0000 0000 OFT2............
00000010: 0000 0000 0001 0001 0001 0001 0000 2ee8 ................
00000020: 0000 2ee8 0000 0000 b164 0000 ffff 0000 .........d......
00000030: 0000 0000 0000 0000 ffff 0000 0000 0000 ................
00000040: ffff 0000 436f 6f6c 2046 696c 6558 6665 ....Cool FileXfe
00000050: 7200 0000 0000 0000 0000 0000 0000 0000 r...............
00000060: 0000 0000 0000 0000 0000 0000 0000 0000 ................
00000070: 0000 0000 0000 0000 0000 0000 0000 0000 ................
00000080: 0000 0000 0000 0000 0000 0000 0000 0000 ................
00000090: 0000 0000 0000 0000 0000 0000 0000 0000 ................
000000a0: 0000 0000 0000 0000 0000 0000 0000 0000 ................
000000b0: 0000 0000 0000 0000 0000 0000 0000 0000 ................
{% endhighlight %}


The flow started with “OFT2”. After a quick lookup, SOME learned that OFT2 is Oscar File Transfer 2, and when they checked the RFC, noticed that the OFT header must start with at least 256 bytes of data. SOME thought it would be good to examine the header, so they looked at it. 

{% highlight bash %}
4F46 5432 0100 0101 F8FA 0200 686B 0000 ProtVer Len Type Cookie
0000 0000 0001 0001 0001 0001 0000 0039 Encrypt Comp TotFil FilLft TotPrts PrtsLft TotSz
0000 0039 42D9 37C4 EEAF 0000 FFFF 0000 Size ModTime Checksum RfrcSum
0000 0000 0000 0000 FFFF 0000 0000 0000 RfSize CreTime RfcSum nRecvd
FFFF 0000 436F 6F6C 2046 696C 6558 6665 RecvCsum IDString
7200 0000 0000 0000 0000 0000 0000 0000 IDString(c'td)
0000 0000 201C 1100 0000 0000 0000 0000 IDString(c'td) Flags NameOff SizeOff Dummy
0000 0000 0000 0000 0000 0000 0000 0000 Dummy(c'td)
0000 0000 0000 0000 0000 0000 0000 0000 Dummy(c'td)
0000 0000 0000 0000 0000 0000 0000 0000 Dummy(c'td)
0000 0000 0000 0000 0000 0000 0000 0000 Dummy(c'td) MacFileInfo
0000 0000 0000 0000 0000 0000 0000 0000 MacFileInfo(c'td) Encoding Subcode
6379 6777 696E 2E62 6174 0000 0000 0000 FileName
0000 0000 0000 0000 0000 0000 0000 0000 FileName(c'td)
0000 0000 0000 0000 0000 0000 0000 0000 FileName(c'td)
0000 0000 0000 0000 0000 0000 0000 0000 FileName(c'td)
{% endhighlight %}


Because SOME is a lazy person, and this is espionage we’re speaking of, they were curious about strings with certain file-extensions. Since OFT2 was involved, a file transfer was present. 

{% highlight bash %}
[arq@darkarq puzzle 1]$ strings 192.168.001.158.05190-192.168.001.159.01272 |grep '.docx\|.xls\|.jpg'
recipe.docx
{% endhighlight %}


A file named recipe.docx had been transferred via OFT2 between the suspect and Ann. SOME, treating the matter as a fantasy, decided to “walk over the file.” Because OFT2 uses a 256-byte header, SOME first removed that header to find the magic number and MD5 sum. 

{% highlight bash %}
[arq@darkarq puzzle 1]$ xxd -s +256 192.168.001.158.05190-192.168.001.159.01272 | xxd -s -256 -r &gt;recipe.docx
[arq@darkarq puzzle 1]$ md5sum recipe.docx
8350582774e1d4dbe1d61d64c89e0ea1 recipe.docx
[arq@darkarq puzzle 1]$ xxd -l 4 -ps recipe.docx
504b0304
{% endhighlight %}


Finally, a file transfer named recipe.docx had indeed taken place between the suspicious device and Ann. The investigation was starting to lead somewhere, but SOME’s weakness for women intervened. After seeing the photograph, SOME also wanted to find Ann’s IM buddy. That could have meaning for future actions.  ￼

Knowing the details of communication—and whether there was additional information in the rest of the conversation—would be important in understanding the suspect’s plans for Ann. From this angle it might even be a counteraction. Was this shady friend actually lying in wait for Ann? 

Therefore, Mr. SOC wanted to have a look at the other flow 192.168.001.158.51128-064.012.024.050.00443

{% highlight bash %}
[arq@darkarq puzzle 1]$ xxd 192.168.001.158.51128-064.012.024.050.00443
00000000: 2a05 0060 0000 2a02 0061 00b7 0004 0006 *..`..*..a......
00000010: 0000 0000 0045 3436 3238 3737 3800 0001 .....E4628778...
00000020: 0b53 6563 3535 3875 7365 7231 0002 008f .Sec558user1....
00000030: 0501 0004 0101 0102 0101 0083 0000 0000 ................
00000040: 4865 7265 2773 2074 6865 2073 6563 7265 Here's the secre
00000050: 7420 7265 6369 7065 2e2e 2e20 4920 6a75 t recipe... I ju
00000060: 7374 2064 6f77 6e6c 6f61 6465 6420 6974 st downloaded it
00000070: 2066 726f 6d20 7468 6520 6669 6c65 2073 from the file s
00000080: 6572 7665 722e 204a 7573 7420 636f 7079 erver. Just copy
00000090: 2074 6f20 6120 7468 756d 6220 6472 6976 to a thumb driv
000000a0: 6520 616e 6420 796f 7527 7265 2067 6f6f e and you're goo
000000b0: 6420 746f 2067 6f20 2667 743b 3a2d 2900 d to go &amp;gt;:-).
000000c0: 0300 002a 0200 6200 2200 0400 1400 0000 ...*..b.".......
000000d0: 0000 4600 0000 0000 0000 0000 010b 5365 ..F...........Se
000000e0: 6335 3538 7573 6572 3100 002a 0200 6300 c558user1..*..c.
000000f0: 7a00 0400 0600 0000 0000 4737 3137 3436 z.........G71746
00000100: 3437 0000 020b 5365 6335 3538 7573 6572 47....Sec558user
00000110: 3100 0300 0000 0500 5200 0037 3137 3436 1.......R..71746
00000120: 3437 0009 4613 434c 7f11 d182 2244 4553 47..F.CL...."DES
00000130: 5400 0000 0200 04c0 a801 9e00 0300 04c0 T...............
00000140: a801 9e00 0500 0214 4600 0a00 0200 0100 ........F.......
00000150: 0f00 0027 1100 1400 0100 0100 002e e872 ...'...........r
00000160: 6563 6970 652e 646f 6378 002a 0200 6400 ecipe.docx.*..d.
00000170: 2200 0400 1400 0000 0000 4800 0000 0000 ".........H.....
00000180: 0000 0000 010b 5365 6335 3538 7573 6572 ......Sec558user
00000190: 3100 022a 0200 6500 4a00 0400 0600 0000 1..*..e.J.......
000001a0: 0000 4935 3038 3834 3936 0000 010b 5365 ..I5088496....Se
000001b0: 6335 3538 7573 6572 3100 0200 2205 0100 c558user1..."...
000001c0: 0401 0101 0201 0100 1600 0000 0073 6565 .............see
000001d0: 2079 6f75 2069 6e20 6861 7761 6969 2100 you in hawaii!.
000001e0: 0300 002a 0200 6600 2200 0400 1400 0000 ...*..f.".......
000001f0: 0000 4a00 0000 0000 0000 0000 010b 5365 ..J...........Se
00000200: 6335 3538 7573 6572 3100 00 c558user1..
{% endhighlight %}

He wanted to check strings first in order to see if there is easly catchable or not. 

{% highlight bash %}
[arq@darkarq puzzle 1]$ strings 192.168.001.158.51128-064.012.024.050.00443
E4628778
Sec558user1
Here's the secret recipe... I just downloaded it from the file server. Just copy to a thumb drive and you're good to go &amp;gt;:-)
Sec558user1
G7174647
Sec558user1
7174647
"DEST
recipe.docx
Sec558user1
I5088496
Sec558user1
see you in hawaii!
Sec558user1
{% endhighlight %}


The output shows clearly that Ann’s IM buddy is Sec558user1. SOME immediately adds them and makes overtures. We don’t know the result. Apart from that, Ann’s message “see you in hawaii!” reveals that she actually has plans involving Hawaii. For SOME, the idea of being with Ann in Hawaii was a super fantasy.  ￼

Leaving fantasies aside, Ann’s responses to the suspect friend also might contain information valuable for continuing the investigation. In that sense, the continuation of the conversation is important. Because this suspicious friend might form a counter-plan against SOME’s plans for Ann. In popular parlance, was this suspect person “Ann’s back-up punch”?

{% highlight bash %}
[arq@darkarq puzzle 1]$ tshark -xr evidence01.pcap tcp.stream==2
0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 2e ab 3b 40 00 40 06 75 0a c0 a8 01 9e 40 0c ...;@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d2 c3 07 e9 60 db 50 18 .2....3k....`.P.
0030 f5 3c 3d 39 00 00 2a 05 00 60 00 00 .&lt;=9..*..`..

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 3d 00 00 7f 06 6d 0e 40 0c 18 32 c0 a8 .(.=....m.@..2..
0020 01 9e 01 bb c7 b8 07 e9 60 db 33 6b d2 c9 50 10 ........`.3k..P.
0030 fa f0 61 f2 00 00 00 00 00 00 00 00 ..a.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 e5 ab 3c 40 00 40 06 74 52 c0 a8 01 9e 40 0c ...&lt;@.@.tR....@.
0020 18 32 c7 b8 01 bb 33 6b d2 c9 07 e9 60 db 50 18 .2....3k....`.P.
0030 f5 3c d0 8c 00 00 2a 02 00 61 00 b7 00 04 00 06 .&lt;....*..a......
0040 00 00 00 00 00 45 34 36 32 38 37 37 38 00 00 01 .....E4628778...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 02 00 8f .Sec558user1....
0060 05 01 00 04 01 01 01 02 01 01 00 83 00 00 00 00 ................
0070 48 65 72 65 27 73 20 74 68 65 20 73 65 63 72 65 Here's the secre
0080 74 20 72 65 63 69 70 65 2e 2e 2e 20 49 20 6a 75 t recipe... I ju
0090 73 74 20 64 6f 77 6e 6c 6f 61 64 65 64 20 69 74 st downloaded it
00a0 20 66 72 6f 6d 20 74 68 65 20 66 69 6c 65 20 73 from the file s
00b0 65 72 76 65 72 2e 20 4a 75 73 74 20 63 6f 70 79 erver. Just copy
00c0 20 74 6f 20 61 20 74 68 75 6d 62 20 64 72 69 76 to a thumb driv
00d0 65 20 61 6e 64 20 79 6f 75 27 72 65 20 67 6f 6f e and you're goo
00e0 64 20 74 6f 20 67 6f 20 26 67 74 3b 3a 2d 29 00 d to go &amp;gt;:-).
00f0 03 00 00 ...

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 41 00 00 7f 06 6d 0a 40 0c 18 32 c0 a8 .(.A....m.@..2..
0020 01 9e 01 bb c7 b8 07 e9 60 db 33 6b d3 86 50 10 ........`.3k..P.
0030 fa f0 61 35 00 00 00 00 00 00 00 00 ..a5........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 50 ab 3d 40 00 40 06 74 e6 c0 a8 01 9e 40 0c .P.=@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d3 86 07 e9 60 db 50 18 .2....3k....`.P.
0030 f5 3c 77 dc 00 00 2a 02 00 62 00 22 00 04 00 14 .&lt;w...*..b."....
0040 00 00 00 00 00 46 00 00 00 00 00 00 00 00 00 01 .....F..........
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 00 .Sec558user1..

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 42 00 00 7f 06 6d 09 40 0c 18 32 c0 a8 .(.B....m.@..2..
0020 01 9e 01 bb c7 b8 07 e9 60 db 33 6b d3 ae 50 10 ........`.3k..P.
0030 fa f0 61 0d 00 00 00 00 00 00 00 00 ..a.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 f9 b4 43 00 00 7f 06 6c 37 40 0c 18 32 c0 a8 ...C....l7@..2..
0020 01 9e 01 bb c7 b8 07 e9 60 db 33 6b d3 ae 50 18 ........`.3k..P.
0030 fa f0 31 e9 00 00 2a 02 56 d4 00 cb 00 01 00 0a ..1...*.V.......
0040 80 00 85 2a 8b 41 00 0e 00 02 00 04 00 00 00 45 ...*.A.........E
0050 00 01 00 02 00 03 00 01 00 01 00 00 00 50 00 00 .............P..
0060 09 c4 00 00 07 d0 00 00 05 dc 00 00 03 20 00 00 ............. ..
0070 17 70 00 00 17 70 00 00 94 dc 00 00 02 00 00 00 .p...p..........
0080 50 00 00 0b b8 00 00 07 d0 00 00 05 dc 00 00 03 P...............
0090 e8 00 00 17 70 00 00 17 70 00 26 01 27 00 00 03 ....p...p.&amp;.'...
00a0 00 00 00 14 00 00 0c 1c 00 00 09 c4 00 00 07 d0 ................
00b0 00 00 05 dc 00 00 11 94 00 00 11 94 12 55 34 eb .............U4.
00c0 00 00 04 00 00 00 14 00 00 15 7c 00 00 14 b4 00 ..........|.....
00d0 00 10 68 00 00 0b b8 00 00 17 70 00 00 1f 40 00 ..h.......p...@.
00e0 26 01 27 00 00 05 00 00 00 0a 00 00 15 7c 00 00 &amp;.'..........|..
00f0 14 b4 00 00 10 68 00 00 0b b8 00 00 17 70 00 00 .....h.......p..
0100 1f 40 00 26 01 27 00 .@.&amp;.'.

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 4e b4 45 00 00 7f 06 6c e0 40 0c 18 32 c0 a8 .N.E....l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 61 ac 33 6b d3 ae 50 18 ........a.3k..P.
0030 fa f0 45 23 00 00 2a 02 56 d5 00 20 00 04 00 0c ..E#..*.V.. ....
0040 00 00 00 00 00 45 34 36 32 38 37 37 38 00 00 01 .....E4628778...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 .Sec558user1

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 3e 40 00 40 06 75 0d c0 a8 01 9e 40 0c .(.&gt;@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d3 ae 07 e9 61 ac 50 10 .2....3k....a.P.
0030 f5 3c 65 f0 00 00 00 00 00 00 00 00 .&lt;e.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 3f 40 00 40 06 75 0c c0 a8 01 9e 40 0c .(.?@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d3 ae 07 e9 61 d2 50 10 .2....3k....a.P.
0030 f5 16 65 f0 00 00 00 00 00 00 00 00 ..e.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 a8 ab 40 40 00 40 06 74 8b c0 a8 01 9e 40 0c ...@@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d3 ae 07 e9 61 d2 50 18 .2....3k....a.P.
0030 f5 16 df 0b 00 00 2a 02 00 63 00 7a 00 04 00 06 ......*..c.z....
0040 00 00 00 00 00 47 37 31 37 34 36 34 37 00 00 02 .....G7174647...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 03 00 00 .Sec558user1....
0060 00 05 00 52 00 00 37 31 37 34 36 34 37 00 09 46 ...R..7174647..F
0070 13 43 4c 7f 11 d1 82 22 44 45 53 54 00 00 00 02 .CL...."DEST....
0080 00 04 c0 a8 01 9e 00 03 00 04 c0 a8 01 9e 00 05 ................
0090 00 02 14 46 00 0a 00 02 00 01 00 0f 00 00 27 11 ...F..........'.
00a0 00 14 00 01 00 01 00 00 2e e8 72 65 63 69 70 65 ..........recipe
00b0 2e 64 6f 63 78 00 .docx.

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 6f 00 00 7f 06 6c dc 40 0c 18 32 c0 a8 .(.o....l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 61 d2 33 6b d4 2e 50 10 ........a.3k..P.
0030 fa f0 5f 96 00 00 00 00 00 00 00 00 .._.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 f9 b4 70 00 00 7f 06 6c 0a 40 0c 18 32 c0 a8 ...p....l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 61 d2 33 6b d4 2e 50 18 ........a.3k..P.
0030 fa f0 a3 2c 00 00 2a 02 56 d6 00 cb 00 01 00 0a ...,..*.V.......
0040 80 00 85 2a c9 63 00 0e 00 02 00 04 00 00 00 47 ...*.c.........G
0050 00 01 00 02 00 03 00 01 00 01 00 00 00 50 00 00 .............P..
0060 09 c4 00 00 07 d0 00 00 05 dc 00 00 03 20 00 00 ............. ..
0070 17 70 00 00 17 70 00 00 5f 77 00 00 02 00 00 00 .p...p.._w......
0080 50 00 00 0b b8 00 00 07 d0 00 00 05 dc 00 00 03 P...............
0090 e8 00 00 17 70 00 00 17 70 00 26 61 09 00 00 03 ....p...p.&amp;a....
00a0 00 00 00 14 00 00 0c 1c 00 00 09 c4 00 00 07 d0 ................
00b0 00 00 05 dc 00 00 11 94 00 00 11 94 12 55 94 cd .............U..
00c0 00 00 04 00 00 00 14 00 00 15 7c 00 00 14 b4 00 ..........|.....
00d0 00 10 68 00 00 0b b8 00 00 17 70 00 00 1f 40 00 ..h.......p...@.
00e0 26 61 09 00 00 05 00 00 00 0a 00 00 15 7c 00 00 &amp;a...........|..
00f0 14 b4 00 00 10 68 00 00 0b b8 00 00 17 70 00 00 .....h.......p..
0100 1f 40 00 26 61 09 00 .@.&amp;a..

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 41 40 00 40 06 75 0a c0 a8 01 9e 40 0c .(.A@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 62 a3 50 10 .2....3k....b.P.
0030 f5 16 64 9f 00 00 00 00 00 00 00 00 ..d.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 4e b4 72 00 00 7f 06 6c b3 40 0c 18 32 c0 a8 .N.r....l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 62 a3 33 6b d4 2e 50 18 ........b.3k..P.
0030 fa f0 3d b3 00 00 2a 02 56 d7 00 20 00 04 00 0c ..=...*.V.. ....
0040 00 00 00 00 00 47 37 31 37 34 36 34 37 00 00 02 .....G7174647...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 .Sec558user1

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 42 40 00 40 06 75 09 c0 a8 01 9e 40 0c .(.B@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 62 c9 50 10 .2....3k....b.P.
0030 f5 16 64 79 00 00 00 00 00 00 00 00 ..dy........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 a9 b4 77 00 00 7f 06 6c 53 40 0c 18 32 c0 a8 ...w....lS@..2..
0020 01 9e 01 bb c7 b8 07 e9 62 c9 33 6b d4 2e 50 18 ........b.3k..P.
0030 fa f0 b7 7d 00 00 2a 02 56 d8 00 7b 00 04 00 07 ...}..*.V..{....
0040 00 00 85 2a d0 7f 37 31 37 34 36 34 37 00 00 02 ...*..7174647...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 00 00 05 .Sec558user1....
0060 00 01 00 02 00 10 00 05 00 04 4a 83 48 06 00 1d ..........J.H...
0070 00 12 00 01 00 05 2b 00 00 31 6e 00 81 00 05 2b ......+..1n....+
0080 00 00 14 4f 00 0f 00 04 00 00 06 e7 00 03 00 04 ...O............
0090 4a 83 a4 85 00 05 00 1a 00 02 37 31 37 34 36 34 J.........717464
00a0 37 00 09 46 13 43 4c 7f 11 d1 82 22 44 45 53 54 7..F.CL...."DEST
00b0 00 00 00 13 00 01 03 .......

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 43 40 00 40 06 75 08 c0 a8 01 9e 40 0c .(.C@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 63 4a 50 10 .2....3k....cJP.
0030 f5 16 63 f8 00 00 00 00 00 00 00 00 ..c.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 50 b4 7b 00 00 7f 06 6c a8 40 0c 18 32 c0 a8 .P.{....l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 63 4a 33 6b d4 2e 50 18 ........cJ3k..P.
0030 fa f0 b4 81 00 00 2a 02 56 d9 00 22 00 04 00 14 ......*.V.."....
0040 00 00 85 2a df 31 00 00 00 00 00 00 00 00 00 01 ...*.1..........
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 02 .Sec558user1..

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 44 40 00 40 06 75 07 c0 a8 01 9e 40 0c .(.D@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 63 72 50 10 .2....3k....crP.
0030 f5 16 63 d0 00 00 00 00 00 00 00 00 ..c.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 01 0a b4 7e 00 00 7f 06 6b eb 40 0c 18 32 c0 a8 ...~....k.@..2..
0020 01 9e 01 bb c7 b8 07 e9 63 72 33 6b d4 2e 50 18 ........cr3k..P.
0030 fa f0 2b 5a 00 00 2a 02 56 da 00 dc 00 04 00 07 ..+Z..*.V.......
0040 00 00 85 2a e4 79 d4 1b 4e ce 87 df 1f 77 00 01 ...*.y..N....w..
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 00 00 05 .Sec558user1....
0060 00 01 00 02 00 10 00 05 00 04 4a 83 48 06 00 1d ..........J.H...
0070 00 12 00 01 00 05 2b 00 00 31 6e 00 81 00 05 2b ......+..1n....+
0080 00 00 14 4f 00 0f 00 04 00 00 06 ef 00 03 00 04 ...O............
0090 4a 83 a4 85 00 02 00 61 05 01 00 01 01 01 01 00 J......a........
00a0 58 00 00 00 00 3c 48 54 4d 4c 3e 3c 42 4f 44 59 X....&lt;HTML&gt;&lt;BODY
00b0 3e 3c 46 4f 4e 54 20 46 41 43 45 3d 22 41 72 69 &gt;&lt;FONT FACE="Ari
00c0 61 6c 22 20 53 49 5a 45 3d 32 20 43 4f 4c 4f 52 al" SIZE=2 COLOR
00d0 3d 23 30 30 30 30 30 30 3e 74 68 61 6e 6b 73 20 =#000000&gt;thanks
00e0 64 75 64 65 3c 2f 46 4f 4e 54 3e 3c 2f 42 4f 44 dude&lt;/FONT&gt;&lt;/BOD
00f0 59 3e 3c 2f 48 54 4d 4c 3e 00 0d 00 12 00 01 00 Y&gt;&lt;/HTML&gt;.......
0100 05 2b 00 00 31 6e 00 81 00 05 2b 00 00 14 4f 00 .+..1n....+...O.
0110 0b 00 00 00 13 00 01 03 ........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 45 40 00 40 06 75 06 c0 a8 01 9e 40 0c .(.E@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 64 54 50 10 .2....3k....dTP.
0030 f5 16 62 ee 00 00 00 00 00 00 00 00 ..b.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 50 b4 84 00 00 7f 06 6c 9f 40 0c 18 32 c0 a8 .P......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 64 54 33 6b d4 2e 50 18 ........dT3k..P.
0030 fa f0 98 e3 00 00 2a 02 56 db 00 22 00 04 00 14 ......*.V.."....
0040 00 00 85 2a f9 c3 00 00 00 00 00 00 00 00 00 01 ...*............
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 02 .Sec558user1..

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 46 40 00 40 06 75 05 c0 a8 01 9e 40 0c .(.F@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 64 7c 50 10 .2....3k....d|P.
0030 f5 16 62 c6 00 00 00 00 00 00 00 00 ..b.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 01 1c b4 8a 00 00 7f 06 6b cd 40 0c 18 32 c0 a8 ........k.@..2..
0020 01 9e 01 bb c7 b8 07 e9 64 7c 33 6b d4 2e 50 18 ........d|3k..P.
0030 fa f0 a0 a3 00 00 2a 02 56 dc 00 ee 00 04 00 07 ......*.V.......
0040 00 00 85 2b 09 51 ce 0b 95 7f 9e 4c 89 9d 00 01 ...+.Q.....L....
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 00 00 05 .Sec558user1....
0060 00 01 00 02 00 10 00 05 00 04 4a 83 48 06 00 1d ..........J.H...
0070 00 12 00 01 00 05 2b 00 00 31 6e 00 81 00 05 2b ......+..1n....+
0080 00 00 14 4f 00 0f 00 04 00 00 06 fd 00 03 00 04 ...O............
0090 4a 83 a4 85 00 02 00 73 05 01 00 01 01 01 01 00 J......s........
00a0 6a 00 00 00 00 3c 48 54 4d 4c 3e 3c 42 4f 44 59 j....&lt;HTML&gt;&lt;BODY
00b0 3e 3c 46 4f 4e 54 20 46 41 43 45 3d 22 41 72 69 &gt;&lt;FONT FACE="Ari
00c0 61 6c 22 20 53 49 5a 45 3d 32 20 43 4f 4c 4f 52 al" SIZE=2 COLOR
00d0 3d 23 30 30 30 30 30 30 3e 63 61 6e 27 74 20 77 =#000000&gt;can't w
00e0 61 69 74 20 74 6f 20 73 65 6c 6c 20 69 74 20 6f ait to sell it o
00f0 6e 20 65 62 61 79 3c 2f 46 4f 4e 54 3e 3c 2f 42 n ebay&lt;/FONT&gt;&lt;/B
0100 4f 44 59 3e 3c 2f 48 54 4d 4c 3e 00 0d 00 12 00 ODY&gt;&lt;/HTML&gt;.....
0110 01 00 05 2b 00 00 31 6e 00 81 00 05 2b 00 00 14 ...+..1n....+...
0120 4f 00 0b 00 00 00 13 00 01 03 O.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 47 40 00 40 06 75 04 c0 a8 01 9e 40 0c .(.G@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 65 70 50 10 .2....3k....epP.
0030 f5 16 61 d2 00 00 00 00 00 00 00 00 ..a.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 50 b4 8d 00 00 7f 06 6c 96 40 0c 18 32 c0 a8 .P......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 70 33 6b d4 2e 50 18 ........ep3k..P.
0030 fa f0 86 d0 00 00 2a 02 56 dd 00 22 00 04 00 14 ......*.V.."....
0040 00 00 85 2b 0a b8 00 00 00 00 00 00 00 00 00 01 ...+............
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 02 .Sec558user1..

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 48 40 00 40 06 75 03 c0 a8 01 9e 40 0c .(.H@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 65 98 50 10 .2....3k....e.P.
0030 f5 16 61 aa 00 00 00 00 00 00 00 00 ..a.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 50 b4 8f 00 00 7f 06 6c 94 40 0c 18 32 c0 a8 .P......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 98 33 6b d4 2e 50 18 ........e.3k..P.
0030 fa f0 83 47 00 00 2a 02 56 de 00 22 00 04 00 14 ...G..*.V.."....
0040 00 00 85 2b 0e 1a 00 00 00 00 00 00 00 00 00 01 ...+............
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 00 .Sec558user1..

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 49 40 00 40 06 75 02 c0 a8 01 9e 40 0c .(.I@.@.u.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 65 c0 50 10 .2....3k....e.P.
0030 f5 16 61 82 00 00 00 00 00 00 00 00 ..a.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 50 ab 4a 40 00 40 06 74 d9 c0 a8 01 9e 40 0c .P.J@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 2e 07 e9 65 c0 50 18 .2....3k....e.P.
0030 f5 16 72 6f 00 00 2a 02 00 64 00 22 00 04 00 14 ..ro..*..d."....
0040 00 00 00 00 00 48 00 00 00 00 00 00 00 00 00 01 .....H..........
0050 0b 53 65 63 35 35 38 75 73 65 72 31 00 02 .Sec558user1..

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 90 00 00 7f 06 6c bb 40 0c 18 32 c0 a8 .(......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 c0 33 6b d4 56 50 10 ........e.3k.VP.
0030 fa f0 5b 80 00 00 00 00 00 00 00 00 ..[.........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 32 ab 4b 40 00 40 06 74 f6 c0 a8 01 9e 40 0c .2.K@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 56 07 e9 65 c0 50 18 .2....3k.V..e.P.
0030 f5 16 36 8d 00 00 2a 02 00 65 00 4a 00 04 00 06 ..6...*..e.J....

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 95 00 00 7f 06 6c b6 40 0c 18 32 c0 a8 .(......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 c0 33 6b d4 60 50 10 ........e.3k.`P.
0030 fa f0 5b 76 00 00 00 00 00 00 00 00 ..[v........

0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 96 ab 4c 40 00 40 06 74 91 c0 a8 01 9e 40 0c ...L@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 60 07 e9 65 c0 50 18 .2....3k.`..e.P.
0030 f5 16 50 dd 00 00 00 00 00 00 00 49 35 30 38 38 ..P........I5088
0040 34 39 36 00 00 01 0b 53 65 63 35 35 38 75 73 65 496....Sec558use
0050 72 31 00 02 00 22 05 01 00 04 01 01 01 02 01 01 r1..."..........
0060 00 16 00 00 00 00 73 65 65 20 79 6f 75 20 69 6e ......see you in
0070 20 68 61 77 61 69 69 21 00 03 00 00 2a 02 00 66 hawaii!....*..f
0080 00 22 00 04 00 14 00 00 00 00 00 4a 00 00 00 00 .".........J....
0090 00 00 00 00 00 01 0b 53 65 63 35 35 38 75 73 65 .......Sec558use
00a0 72 31 00 00 r1..

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 28 b4 96 00 00 7f 06 6c b5 40 0c 18 32 c0 a8 .(......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 c0 33 6b d4 ce 50 10 ........e.3k..P.
0030 fa f0 5b 08 00 00 00 00 00 00 00 00 ..[.........

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 f9 b4 97 00 00 7f 06 6b e3 40 0c 18 32 c0 a8 ........k.@..2..
0020 01 9e 01 bb c7 b8 07 e9 65 c0 33 6b d4 ce 50 18 ........e.3k..P.
0030 fa f0 38 6b 00 00 2a 02 56 df 00 cb 00 01 00 0a ..8k..*.V.......
0040 80 00 85 2b 20 40 00 0e 00 02 00 04 00 00 00 49 ...+ @.........I
0050 00 01 00 02 00 03 00 01 00 01 00 00 00 50 00 00 .............P..
0060 09 c4 00 00 07 d0 00 00 05 dc 00 00 03 20 00 00 ............. ..
0070 17 70 00 00 17 70 00 00 0c 61 00 00 02 00 00 00 .p...p...a......
0080 50 00 00 0b b8 00 00 07 d0 00 00 05 dc 00 00 03 P...............
0090 e8 00 00 17 70 00 00 17 70 00 26 df bb 00 00 03 ....p...p.&amp;.....
00a0 00 00 00 14 00 00 0c 1c 00 00 09 c4 00 00 07 d0 ................
00b0 00 00 05 dc 00 00 11 94 00 00 11 94 12 56 13 7e .............V.~
00c0 00 00 04 00 00 00 14 00 00 15 7c 00 00 14 b4 00 ..........|.....
00d0 00 10 68 00 00 0b b8 00 00 17 70 00 00 1f 40 00 ..h.......p...@.
00e0 26 df bb 00 00 05 00 00 00 0a 00 00 15 7c 00 00 &amp;............|..
00f0 14 b4 00 00 10 68 00 00 0b b8 00 00 17 70 00 00 .....h.......p..
0100 1f 40 00 26 df bb 00 .@.&amp;...

0000 00 12 79 45 a4 bb 00 0c 29 b0 8d 62 08 00 45 00 ..yE....)..b..E.
0010 00 4e b4 99 00 00 7f 06 6c 8c 40 0c 18 32 c0 a8 .N......l.@..2..
0020 01 9e 01 bb c7 b8 07 e9 66 91 33 6b d4 ce 50 18 ........f.3k..P.
0030 fa f0 3d 13 00 00 2a 02 56 e0 00 20 00 04 00 0c ..=...*.V.. ....
0040 00 00 00 00 00 49 35 30 38 38 34 39 36 00 00 01 .....I5088496...
0050 0b 53 65 63 35 35 38 75 73 65 72 31 .Sec558user1
0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 4d 40 00 40 06 74 fe c0 a8 01 9e 40 0c .(.M@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 ce 07 e9 66 91 50 10 .2....3k....f.P.
0030 f5 16 60 11 00 00 00 00 00 00 00 00 ..`.........
0000 00 0c 29 b0 8d 62 00 12 79 45 a4 bb 08 00 45 00 ..)..b..yE....E.
0010 00 28 ab 4e 40 00 40 06 74 fd c0 a8 01 9e 40 0c .(.N@.@.t.....@.
0020 18 32 c7 b8 01 bb 33 6b d4 ce 07 e9 66 b7 50 10 .2....3k....f.P.
0030 f5 16 5f eb 00 00 00 00 00 00 00 00 .._.........
{% endhighlight %}


Although in the output SOME could see the messages, Mr. SOC thought this output could have been larger, and wondered how else they might examine it. Then they wanted to see the detailed contents of the relevant stream.

{% highlight bash %}
[arq@darkarq puzzle 1]$ tshark -r evidence01.pcap tcp.stream==2
23 18.870898 192.168.1.158 -&gt; 64.12.24.50 SSL 60 Continuation Data
24 18.871477 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1 Ack=7 Win=64240 Len=0
25 33.914966 192.168.1.158 -&gt; 64.12.24.50 SSL 243 Continuation Data
26 33.915486 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1 Ack=196 Win=64240 Len=0
27 34.006599 192.168.1.158 -&gt; 64.12.24.50 SSL 94 Continuation Data
28 34.006604 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1 Ack=236 Win=64240 Len=0
29 34.023247 64.12.24.50 -&gt; 192.168.1.158 SSL 263 Continuation Data
31 34.025537 64.12.24.50 -&gt; 192.168.1.158 SSL 92 Continuation Data
32 34.026804 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=236 Ack=210 Win=62780 Len=0
33 34.026809 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=236 Ack=248 Win=62742 Len=0
92 58.458768 192.168.1.158 -&gt; 64.12.24.50 SSL 182 Continuation Data
93 58.461856 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=248 Ack=364 Win=64240 Len=0
94 58.568705 64.12.24.50 -&gt; 192.168.1.158 SSL 263 Continuation Data
96 58.569716 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=457 Win=62742 Len=0
97 58.571268 64.12.24.50 -&gt; 192.168.1.158 SSL 92 Continuation Data
98 58.574447 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=495 Win=62742 Len=0
136 61.287474 64.12.24.50 -&gt; 192.168.1.158 SSL 183 Continuation Data
137 61.288392 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=624 Win=62742 Len=0
161 67.395187 64.12.24.50 -&gt; 192.168.1.158 SSL 94 Continuation Data
162 67.395540 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=664 Win=62742 Len=0
167 69.578667 64.12.24.50 -&gt; 192.168.1.158 SSL 280 Continuation Data
168 69.579120 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=890 Win=62742 Len=0
179 77.834511 64.12.24.50 -&gt; 192.168.1.158 SSL 94 Continuation Data
180 77.834516 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=930 Win=62742 Len=0
184 83.489593 64.12.24.50 -&gt; 192.168.1.158 SSL 298 Continuation Data
185 83.489598 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=1174 Win=62742 Len=0
190 83.906524 64.12.24.50 -&gt; 192.168.1.158 SSL 94 Continuation Data
191 83.907211 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=1214 Win=62742 Len=0
196 84.995484 64.12.24.50 -&gt; 192.168.1.158 SSL 94 Continuation Data
197 84.995488 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=364 Ack=1254 Win=62742 Len=0
200 87.726166 192.168.1.158 -&gt; 64.12.24.50 SSL 94 Continuation Data
201 87.726936 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1254 Ack=404 Win=64240 Len=0
210 90.788876 192.168.1.158 -&gt; 64.12.24.50 SSL 64 Continuation Data
211 90.789489 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1254 Ack=414 Win=64240 Len=0
212 90.816866 192.168.1.158 -&gt; 64.12.24.50 SSL 164 Continuation Data
213 90.817354 64.12.24.50 -&gt; 192.168.1.158 TCP 60 443→51128 [ACK] Seq=1254 Ack=524 Win=64240 Len=0
214 91.003314 64.12.24.50 -&gt; 192.168.1.158 SSL 263 Continuation Data
216 91.004650 64.12.24.50 -&gt; 192.168.1.158 SSL 92 Continuation Data
217 91.033478 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=524 Ack=1463 Win=62742 Len=0
218 91.033482 192.168.1.158 -&gt; 64.12.24.50 TCP 60 51128→443 [ACK] Seq=524 Ack=1501 Win=62742 Len=0
{% endhighlight %}


Since the flow containing responses concerning IP 64.12.24.50 was listed in the tcpflow output, extracting the strings inside it would be more practical.

{% highlight bash %}
[arq@darkarq puzzle 1]$ strings 064.012.024.050.00443-192.168.001.158.51128
E4628778
Sec558user1*
G7174647
Sec558user1*
7174647
Sec558user1
7174647
"DEST
Sec558user1
Sec558user1
&lt;HTML&gt;&lt;BODY&gt;&lt;FONT FACE="Arial" SIZE=2 COLOR=#000000&gt;thanks dude&lt;/FONT&gt;&lt;/BODY&gt;&lt;/HTML&gt;
Sec558user1
Sec558user1
&lt;HTML&gt;&lt;BODY&gt;&lt;FONT FACE="Arial" SIZE=2 COLOR=#000000&gt;can't wait to sell it on ebay&lt;/FONT&gt;&lt;/BODY&gt;&lt;/HTML&gt;
Sec558user1
Sec558user1
I5088496
Sec558user1
{% endhighlight %}

He reached two important conclusions from these data. The suspect could not be Ann’s partner because he addressed her as “dude”. He rejoiced, thinking nobody would call their lover “dude.” In addition, whatever information the suspect had obtained was something that could be put up for sale on eBay.

While the investigation had reached a meaningful conclusion, SOME thought that by opening the pcap in Wireshark, filtering for Ann’s IP and decoding the relevant TCP stream in AIM format to “Follow” it, he could arrive at the same results. But that would be too easy. He wanted to try many different tools and proceed like solving a puzzle. That way he could spend more time with Ann. Otherwise he would have a premature climax.

SOME left a note for the curious: try to avoid leaving the command line as much as possible — it’s more enjoyable. Chase what you love, even if it’s in Hawaii.

See you in the second post.

