---
layout: post
title: Some'nin Maceraları Bölüm III
date: 2015-10-20 14:26
comments: true
lang: tr
permalink: /tr/articles/2015-10/some-nin-maceralari-b-ol-um-iii/
---
Bir onceki bolumde Ann’in gizli asigi olan Mr.X’e gonderdigi mesaji gormustuk. Mesajda buyuk miktarda nakit ile birlikte Meksika kiyilarina kacma planlari yapilmaktaydi. Ote yandan ogrenilen son bilgiler kahramanimiz SOME icin tam bir hayalkirikligi niteligi tasimaktaydi. <!--more-->Zira SOME, linkedin resminden vuruldugu bu hatuna yurume derdindeydi. Her sisman analist gibi, evinden cikmadan, internet uzerinden armut pis agzima dus seklinde bir iliskinin oluru pesindeydi. Bu noktada gizli asiga gonderilen mesaj SOME’nin umutlarini bir nebze olsun kirmis ama armutun da sapi var diyerekten, Polisle is birligi yapmaya devam etme karari almisti.

Evet malum gizli bilgiler ifsa oldugundan olay polise aksetmisti. Polis Ann ile Mr.X’in kullandigi bi eve baskin duzenledi ve Ev icerisinde Ann’a ait oldugu dusunulen bir Apple TV ele gecirildi. Apple TV’ye ait trafik dosyasi uzerinden Ann ve Mr.X hakkinda bir bilgi edinilebilir mi incelenmesi icin yine SOME gorevdeydi.

SOME yine resmin buyugunu gormek adina ilk once adi gecen protokollere bir goz atmak istedi.

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

Enteresan bir protokol goremeyen SOME network icerisindeki gurultu duzeyini inceleyerek analizine devam etti

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

Bu noktada tek bir yerel IP adresini olusturan 192.168.1.10 buyuk ihtimalle Apple TV cihazinin adresiydi, fakat yine de bunu dogrulamasi gerekecekti. Bir analist daima supheci olmali diye gecirdi aklindan. Bunun icin oncelikle IP ve MAC ikililerini listelemek istedi.

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

Peki bu MAC adresi gercekten Apple TV’ye mi aitti? Bunun icin 00:25::00 kisminin google aranmasi yeterliydi.

SOME protokol listesinde gordugu HTTP protokolu uzerinden giden trafik icin user-agent bilgisini sorgulamak istedi. Bu trafigin Apple TV tarafindan yapildigini tahmin etse de dogrulamak istiyordu.

{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Tfields -e http.user_agent -r evidence03.pcap | sort -u
AppleTV/2.
{% endhighlight %}

<strong>User-Agent</strong> sonucunda trafigin cihazdan geldigini dogrulamis oldu. Bu noktadan sonra merak ettigi sey HTTP protokolu uzerinden gonderilen isteklerin uri’leri oldugundan, genel goz atmak maksatiyla yapilan isteklere bakti.

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


Yapilan istekleri incelediginde belirli bir pattern oldugunu gormesi gec olmadi. Normal HTTP isteklerinin tamaminda <em><strong>%2FWebObjects%2FMZSearch.woa%2Fwa%2F</strong></em> pathini gordugunden kucuk bir python scripti ile ilgili kismi trafik dosyasi icerisinden cekmek istedi.


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


Python scriptini calistirdiginda


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

sonucuna ulasti. Bu noktada kendisine neden python scripti yazdigini sordu ve gulumsedi. Zira ayni ciktiyi tshark ve awk kullanarak da elde edebilirdi diye dusundu. Dogrulamak icin ilgili komutu calistirdi


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

Cikti artik daha sadeydi ve gozlerine inanamadi. Siradan bir calisan olarak dusundugu Ann’a ait Apple TV’de Ann ona mesaj birakmisti. Ve izlendiginden haberdardi. Izlendiginden haberdar olmasi normaldi ancak asil SOME’yi sasirtan sey, Ann’in olasi yapilacak bir forensics investigation sirasinda bu mesajlari okunabilecegini tahmin etmesiydi. Mesajda iknowyourewatchingme yaziyordu.

Bu noktada SOME, karsisindaki kadinin aslinda siradan bir calisandan ziyade belirli teknik konulara temel duzeyde bilgi sahibi olan bir kadin oldugunu farketti. Cok sasirmisti. Zira SOME, klavyede on parmak yazi yazan kadinlari bile cekici bulurken, bu duzeyde bilgi sahibi olan bir kadin SOME’nin gozunde cok daha anlamli bir yere gelmisti bile.

Butun bunlar kafasindan gecerken Apptle TV uzerinde Ann’in bir sey izleyip izlemedigi sorusu aklina geldi. Buna bakmak icin arama kriterini biraz daha daraltarak Apple Tv nin karakteristigi olan viewMovie sayfasina istek olup olmadigini inceledi.


{% highlight bash %}
[arq@darkarq puzzle 3]$ tshark -Y "http.request.uri contains viewMovie" -Tfields -e http.request.uri -r evidence03.pcap
/WebObjects/MZStore.woa/wa/viewMovie?id=333441649&amp;s=143441
/b/ss/applesuperglobal/1/G.6--NS?pageName=Movie%20Page-US-Hackers-Iain%20Softley-333441649&amp;pccr=true&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;ch=Movie%20Page&amp;g=http%3A%2F%2Fax.itunes.apple.com%2FWebObjects%2FMZStore.woa%2Fwa%2FviewMovie%3Fid%3D333441649%26s%3D143441
/WebObjects/MZStore.woa/wa/viewMovie?id=283963264&amp;s=143441
/b/ss/applesuperglobal/1/G.6--NS?pageName=Movie%20Page-US-Sneakers-Phil%20Alden%20Robinson-283963264&amp;pccr=true&amp;h5=appleitmsnatv%2Cappleitmsustv&amp;ch=Movie%20Page&amp;g=http%3A%2F%2Fax.itunes.apple.com%2FWebObjects%2FMZStore.woa%2Fwa%2FviewMovie%3Fid%3D283963264%26s%3D143441
{% endhighlight %}

Hackers ve Sneakers isimli iki videonun izlendigini gordu. Bu videolar aslinda Ann ve gizli sevgilisinin Hack kavramini gundelik mesaisi icinde de gecirdigini dolayisi ile dusunuldugunden daha fazla mesai harcadiklarini anlamis oldu.

Polis Ann ve sevgilisini elinden kacirmisti. SOME “simdi meksika’da olmalilar” diye aklindan gecirdi. Polis ise evi guvenlik cemberine alarak olay yeri inceleme ekiplerinin tam bir arama yapmalarini beklemeye baslamisti.


