---
layout: post
title: The Adventure of Mr. SOC III
date: 2015-10-20 14:26
comments: true
lang: tr
categories: [Siber Güvenlik, Adli Bilişim, Olay Müdahale,]
permalink: /en/articles/2015-10/the-adventure-of-mr-soc-iii/

---

In the previous installment, we saw the message Ann had sent to her secret lover Mr. X. In that message they were planning to escape to the Mexican coast with a large amount of cash. On the other hand, the most recently uncovered information was something of a disappointment for our hero MMr. SOC. <!--more-->Because he, struck by Ann’s LinkedIn photo, was hoping for a romantic pursuit from afar. Like many overweight analysts, he was chasing love without even leaving the house, expecting a pear to fall into his mouth.

At this point, the revelation that Ann had sent a message to her secret lover somewhat shattered Mr. SOC’s hopes, but he decided — fruit stem or not — to continue cooperating with the police.

Yes, since the sensitive information had been leaked, the case had come to the attention of the police. The police conducted a raid on a house used by Ann and Mr. X, and an Apple TV believed to belong to Ann was seized inside the house. Mr. SOC was once again assigned the task of determining whether any useful information about Ann and Mr. X could be obtained from the network-traffic file associated with the Apple TV.

To see the larger picture, as usual Mr. SOC first looked at the protocols mentioned in the traffic capture.

{% highlight bash %}
[arq@darkarq puzzle 2]$ tshark -r evidence03.pcap -zio,phs
===================================================================
Protocol Hierarchy Statistics
Filter:

eth frames:1778 bytes:1508750
ip frames:1778 bytes:1508750
udp frames:28 bytes:6102
dns frames:28 bytes:6102
tcp frames:1750 bytes:1502648
http frames:232 bytes:139658
xml frames:35 bytes:32584
tcp.segments frames:17 bytes:11732
image-gif frames:33 bytes:21202
image-jfif frames:46 bytes:34175
tcp.segments frames:46 bytes:34175
media frames:2 bytes:562
tcp.segments frames:2 bytes:562
===================================================================
{% endhighlight %}

Mr. SOC didn’t immediately see any unusual protocol; he continued his analysis by inspecting the noise level in the network.

{% highlight bash %}
[arq@darkarq puzzle 3]$ tcpdump -tnr evidence03.pcap | awk -F '.' '{print $1"."$2"."$3"."$4}'|sort|uniq -c |sort -n |tailreading from file evidence03.pcap, link-type EN10MB (Ethernet)
15 IP 8.18.65.88
20 IP 8.18.65.89
28 IP 8.18.65.32
36 IP 8.18.65.67
39 IP 8.18.65.27
55 IP 66.235.132.121
129 IP 8.18.65.58
285 IP 8.18.65.10
518 IP 8.18.65.82
642 IP 192.168.1.10
{% endhighlight %}

At this point, the single local IP address 192.168.1.10 was very likely the Apple TV device, but he thought he still needed to verify that. A good analyst should always remain suspicious. For that, he first wanted to list the IP-MAC pairs.

{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -r evidence03.pcap -T fields -e eth.src -e ip.src |sort|uniq
00:23:69:ad:57:7b 4.2.2.1
00:23:69:ad:57:7b 66.235.132.121
00:23:69:ad:57:7b 8.18.65.10
00:23:69:ad:57:7b 8.18.65.27
00:23:69:ad:57:7b 8.18.65.32
00:23:69:ad:57:7b 8.18.65.58
00:23:69:ad:57:7b 8.18.65.67
00:23:69:ad:57:7b 8.18.65.82
00:23:69:ad:57:7b 8.18.65.88
00:23:69:ad:57:7b 8.18.65.89
00:25:00:fe:07:c4 192.168.1.10
{% endhighlight %}

Is that MAC address really associated with Apple TV? For that, searching “00:25:00” on Google was enough to confirm.

In the protocol list Mr. SOC saw HTTP traffic among them; for that traffic he wanted to examine the User-Agent string. Even though he suspected that the traffic originated from the Apple TV, he wanted to verify.

{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Tfields -e http.user_agent -r evidence03.pcap | sort -u
AppleTV/2.
{% endhighlight %}

From the User Agent result, he confirmed that the traffic did indeed come from the device. From this point he was interested in the request URIs sent via HTTP; out of curiosity, he inspected the URIs of the requests generally.

{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Y "http.request.uri" -Tfields -e http.request.uri -r evidence03.pcap | head
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dh&amp;pageName=Movies-Search%20Hints-US&amp;v2=h&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=h
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dha&amp;pageName=Movies-Search%20Hints-US&amp;v2=ha&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=ha
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dhac&amp;pageName=Movies-Search%20Hints-US&amp;v2=hac&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=hac
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dhack&amp;pageName=Movies-Search%20Hints-US&amp;v2=hack&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=hack
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Ds&amp;pageName=Movies-Search%20Hints-US&amp;v2=s&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=s
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dsn&amp;pageName=Movies-Search%20Hints-US&amp;v2=sn&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=sn
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dsne&amp;pageName=Movies-Search%20Hints-US&amp;v2=sne&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=sne
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dsneb&amp;pageName=Movies-Search%20Hints-US&amp;v2=sneb&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=sneb
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dsnea&amp;pageName=Movies-Search%20Hints-US&amp;v2=snea&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=snea
/b/ss/applesuperglobal/1/G.6--NS?pccr=true&amp;ch=Movies-Search&amp;g=http%3A%2F%2Fax.search.itunes.apple.com%2FWebObjects%2FMZSearch.woa%2Fwa%2FincrementalSearch%3Fmedia%3Dmovie%26q%3Dsneak&amp;pageName=Movies-Search%20Hints-US&amp;v2=sneak&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;c2=sneak
{% endhighlight %}


When examining those requests, Mr. SOC noticed a pattern. Since in all of the ordinary HTTP requests he saw the path %2FWebObjects%2FMZSearch.woa%2Fwa%%2F (encoded), he wrote a small Python script to extract the relevant portion from the traffic file.


{% highlight python %}
#!/usr/bin/python 
import pcapy 
import impacket.ImpactDecoder as Decoders 

reader = pcapy.open_offline("evidence03.pcap") 
(header, payload) = reader.next() 

while payload!='': 
 try: 
  decoder = Decoders.EthDecoder() 
  eth = decoder.decode(payload) 
  ip = eth.child() 
  tcp = ip.child() 
  data = tcp.get_data_as_string() 
  arrline = data.split('\x0d\x0a') 
  for line in arrline: 
    if line.startswith("GET /WebObjects"): 
       line = line.replace('GET /WebObjects/MZStore.woa/wa/', '') 
       line = line.replace('GET /WebObjects/MZSearch.woa/wa/', '') 
    print line 
   (header, payload) = reader.next() 
 except: 
  break
{% endhighlight %}


When he ran the Python script, he got:


{% highlight bash %}
viewGrouping?id=39 HTTP/1.1 
incrementalSearch?media=movie&amp;q=h HTTP/1.1 
incrementalSearch?media=movie&amp;q=ha HTTP/1.1 
incrementalSearch?media=movie&amp;q=hac HTTP/1.1 
incrementalSearch?media=movie&amp;q=hack HTTP/1.1 
viewMovie?id=333441649&amp;s=143441 HTTP/1.1 
relatedItemsShelf?ct-id=3&amp;id=333441649&amp;storeFrontId=143441&amp;mt=6 HTTP/1.1 
incrementalSearch?media=movie&amp;q=s HTTP/1.1 
incrementalSearch?media=movie&amp;q=sn HTTP/1.1 
incrementalSearch?media=movie&amp;q=sne HTTP/1.1 
incrementalSearch?media=movie&amp;q=sneb HTTP/1.1 
incrementalSearch?media=movie&amp;q=snea HTTP/1.1 
incrementalSearch?media=movie&amp;q=sneak HTTP/1.1 
viewMovie?id=283963264&amp;s=143441 HTTP/1.1 
relatedItemsShelf?ct-id=3&amp;id=283963264&amp;storeFrontId=143441&amp;mt=6 HTTP/1.1 
incrementalSearch?media=movie&amp;q=i HTTP/1.1 
incrementalSearch?media=movie&amp;q=ik HTTP/1.1 
incrementalSearch?media=movie&amp;q=ikn HTTP/1.1 
incrementalSearch?media=movie&amp;q=ikno HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknow HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowy HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyo HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyou HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyour HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyoure HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourew HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewa HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewat HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatc HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatch HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatchi HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatchin HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatching HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatchingm HTTP/1.1 
incrementalSearch?media=movie&amp;q=iknowyourewatchingme HTTP/1.1
{% endhighlight %}

At this point he asked himself why he had written the Python script, and smiled. Because he thought: he could have gotten the same output using tshark and awk. To verify, he ran the appropriate command:


{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Y "http.request.uri contains search" -Tfields -e http.request.uri -r evidence03.pcap | awk -F"=" '{print $NF}'
h
ha
hac
hack
s
sn
sne
sneb
snea
sneak
i
ik
ikn
ikno
iknow
iknowy
iknowyo
iknowyou
iknowyour
iknowyoure
iknowyourew
iknowyourewa
iknowyourewat
iknowyourewatc
iknowyourewatch
iknowyourewatchi
iknowyourewatchin
iknowyourewatching
iknowyourewatchingm
iknowyourewatchingme
{% endhighlight %}

The output was now more concise — and he could hardly believe his eyes. On Ann’s Apple TV, the woman he had thought was just an ordinary worker, Ann had left a message for him. And she was aware that she was being watched. What surprised Mr. SOC even more was that she had anticipated that these messages could be read in a possible forensics investigation. The message was: iknowyourewatchingme

At this point Mr. SOC realized that the woman across from him was not just an ordinary employee but someone with at least a basic knowledge of technical matters. He was very surprised. Because he, who finds women who can touch type attractive, found a woman knowing this level of detail to be much more meaningful already in his eyes.

While all this was passing through his mind, the question came to him: whether Ann was actually watching something on Apple TV. To check, he narrowed the search criteria a little more by looking for requests to the viewMovie page characteristic of Apple TV.


{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Y "http.request.uri contains viewMovie" -Tfields -e http.request.uri -r evidence03.pcap
/WebObjects/MZStore.woa/wa/viewMovie?id=333441649&amp;s=143441
/b/ss/applesuperglobal/1/G.6--NS?pageName=Movie%20Page-US-Hackers-Iain%20Softley-333441649&amp;pccr=true&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;ch=Movie%20Page&amp;g=http%3A%2F%2Fax.itunes.apple.com%2FWebObjects%2FMZStore.woa%2Fwa%2FviewMovie%3Fid%3D333441649%26s%3D143441
/WebObjects/MZStore.woa/wa/viewMovie?id=283963264&amp;s=143441
/b/ss/applesuperglobal/1/G.6--NS?pageName=Movie%20Page-US-Sneakers-Phil%20Alden%20Robinson-283963264&amp;pccr=true&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;ch=Movie%20Page&amp;g=http%3A%2F%2Fax.itunes.apple.com%2FWebObjects%2FMZStore.woa%2Fwa%2FviewMovie%3Fid%3D283963264%26s%3D143441
{% endhighlight %}

He saw that two videos, Hackers and Sneakers, had been watched. These movies were meaningful because Ann and her secret lover used the concept of “Hack” in their daily work life; it meant they were spending more time than normally assumed.

The police had missed Ann and her lover. Mr. SOC thought to himself, “They must be in Mexico by now.” Meanwhile, the police surrounded the house with a security cordon and awaited the evidence-team for a full forensic investigation.


