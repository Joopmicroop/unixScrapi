#! /bin/bash

outdir="out"
linksFile="links.tmp"

# echo "fetching all links of $1/$2.html"
# lynx -listonly -nonumbers -dump "$1" | grep "$1" >> "$linksFile"
# echo "saved $linksfile"

echo -e "\e[33msitemap file name (sitemap.xml): \e[0m";
read sitemapFile
if [ -z "$sitemapFile" ]
then
  sitemapFile="sitemap.xml"
  #else
  #echo "not Empty"
fi
echo -e "\e[32msitemap file is '$sitemapFile'\e[0m";

echo "starting to fetch urls from sitemap.";
./sitemapToUrlList.sh "$sitemapFile" > links.tmp
echo -e "\e[2m $(cat links.tmp) \e[0m"

echo "creating '$outdir' directory"
mkdir "$outdir"

while read fullUrl; do
  echo -e "\e[32mprocessing: $fullUrl \e[0m"
  
  # extract the protocol
  proto="$(echo $fullUrl | grep :// | sed -e's,^\(.*://\).*,\1,g')"
  # remove the protocol
  url="$(echo ${fullUrl/$proto/})"
  # extract the user (if any)
  user="$(echo $url | grep @ | cut -d@ -f1)"
  # extract the host
  host="$(echo ${url/$user@/} | cut -d/ -f1)"
  # by request - try to extract the port
  port="$(echo $host | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
  # extract the path (if any)
  path="$(echo $url | grep / | cut -d/ -f2-)"
  # extract the extension
  ext="$(echo $path | cut -d. -f2-)"
  # extract filename
	fn="$(basename ${fullUrl##*/} .html)"
	if [ $fn = ".html" ]
	then
		fn="index"
		ext="html"
		path="$fn.$ext"
	fi

  
  echo "url: $url"
  echo "  proto: $proto"
  echo "  user: $user"
  echo "  host: $host"
  echo "  port: $port"
  echo "  path: $path"
  echo "  name: $fn"
  echo "  ext: $ext"
  
  echo -e "\e[32mfetching $fullUrl \e[0m"
  lynx --dump "$fullUrl" --nolist > "$outdir/$fn"
  echo -e "\e[32msaved $outdir/$fn \e[0m"
  echo -e "\e[2m--------------------------------------------------------------------------------------------\e[0m"
  #sleep 1;
 
done <links.tmp # pass each line of the file trough to while read url

# download the images too
# wget -nd -r -P /outImg -A jpeg,jpg,bmp,gif,png http://www.ajediam.com



