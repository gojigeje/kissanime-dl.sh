#!/bin/bash
# ----------------------------------------------------------------------------------
# @name    : kissanime-360.sh
# @version : 0.1
# @date    : 2015/03/09 11:04 WIB
#
# TENTANG
# ----------------------------------------------------------------------------------
# Script untuk link-grabbing (mengambil link) video dari kissanime.com,
# Setelah grabbing link, script akan membuat halaman html yang berisi link
# video dari hasil grabbing tersebut.
#
# NB:
# Karena sistem kissanime.com yang mengharuskan login untuk menampilkan link
# download video, script ini hanya bisa mengambil link video versi 360p saja
#
# KONTAK
# ----------------------------------------------------------------------------------
# Ada bug? saran? sampaikan ke saya.
# Ghozy Arif Fajri / gojigeje
# email    : gojigeje@gmail.com
# web      : goji.web.id
# facebook : facebook.com/gojigeje
# twitter  : @gojigeje
# G+       : gplus.to/gojigeje
#
# LISENSI
# ----------------------------------------------------------------------------------
# Open Source tentunya :)
#  The MIT License (MIT)
#  Copyright (c) 2013 Ghozy Arif Fajri <gojigeje@gmail.com>

mulai() {
   # secara default, file html berisi link video akan disimpan ke Desktop
   # ganti sesuai keperluan
   downloadFolder="$HOME/Desktop"

   clear
   figlet " KissAnime-DL"
   echo " KissAnime.com video link grabber by @gojigeje <gojigeje@gmail.com>"
   echo ""

   pageurl="$1"
   target=$(echo "$pageurl" | sed 's/kissanime.com\//proksi.ml\/kissanime.com\//g')
   cek_koneksi
   cekLink "$target"
   verifyPage "$target"
   ua="Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36"

}

cek_koneksi() {
  if eval "ping -c 1 8.8.4.4 -w 2 > /dev/null"; then
    echo "# [`date +%Y-%m-%d` `date +%H:%M`] - Cek koneksi internet.. [OK] "
  else
    echo "# [`date +%Y-%m-%d` `date +%H:%M`] - EXIT: Nggak konek internet :("
    exit
  fi

  # # cara lain cek online dengan curl, jika ping diblok sama admin jaringan
  # respon=$(curl -sI http://www.google.co.id/ | head -n 1 | cut -d " " -f2)
  # if [[ $respon == 200 ]]; then
  #   echo "# [`date +%Y-%m-%d` `date +%H:%M`] - Cek koneksi internet.. [OK] "
  # else
  #   echo "# [`date +%Y-%m-%d` `date +%H:%M`] - EXIT: Nggak konek internet :("
  #   exit
  # fi
}

cekLink() {
   tempFile=".kisstemp"
   tempLink=".kisstempLink"
   linkFile=".kisslink"

   link="$target"
   cLink=$(echo $link | sed 's/http:\/\///g' | sed 's/\/$//g')
   cSitus=$(echo $cLink | cut -d "/" -f2)
   cAnime=$(echo $cLink | cut -d "/" -f3)
   cJudul=$(echo $cLink | cut -d "/" -f4)
   cEpisode=$(echo $cLink | cut -d "/" -f5)

   echo "cLink: $cLink ~ cSitus: $cSitus ~ cAnime: $cAnime ~ cJudul: $cJudul ~ cEpisode: $cEpisode"

   if [[ "$cSitus" = "kissanime.com" || "$cSitus" = "www.kissanime.com" ]]; then
      if [[ -z "$cEpisode" ]]; then
         if [[ -z "$cJudul" ]]; then
            linkSalah="1"
         else
            if [[ "$cAnime" = "Anime" ]]; then
              # echo "episode full!"
               dlTipe="Anime"
            else
               linkSalah="1"
            fi
         fi
      else
        # cek range?
        if echo "$cEpisode" | egrep -E '^#[0-9]{1,3}-[0-9]{1,3}$' > /dev/null ;then
          epsMin=$(printf "%03d" `echo "$cEpisode" | sed -s 's/#//g' | cut -d "-" -f1`)
          epsMax=$(printf "%03d" `echo "$cEpisode" | sed -s 's/#//g' | cut -d "-" -f2`)

          if [[ $epsMin -gt $epsMax ]]; then
            echo "# [ERROR] urutan episode terbalik! --> #[min]-[max]"
            echo ""
            exit
          else
            dlTipe="Range"
            target=$(echo $target | sed 's/\/#.*//g')
          fi
        # start+
        elif echo "$cEpisode" | egrep -E '^#[0-9]{1,3}\+$' > /dev/null ;then
          dlTipe="RangePlus"
          target=$(echo $target | sed 's/\/#.*//g')
          epss=$(echo "$cEpisode" | sed -s 's/#//g' | cut -d "+" -f1)
          let epss--;
          epsMin=$(printf "%03d" $epss)
        # single
        elif echo "$cEpisode" | egrep -E '^#[0-9]{1,3}$' > /dev/null ;then
          dlTipe="Episode"
          epss=$(printf "%03d" `echo "$cEpisode" | sed -s 's/#//g' | cut -d "-" -f1`)
          target=$(echo $target | sed 's/#.*/Episode-'$epss'/g')
        elif echo "$cEpisode" | egrep -E '^#last$' > /dev/null ;then
          dlTipe="Last"
        else
          adaEpisode=$(echo $cEpisode | grep "Episode" | wc -l)
          if [[ $adaEpisode -gt 0 ]]; then
             dlTipe="Episode"
          else
             linkSalah="1"
          fi
        fi

      fi
   else
      linkSalah="1"
   fi

   if [[ $linkSalah -gt 0 ]]; then
      echo "#"
      echo "# [-ERROR-] Link Salah! Script hanya bisa mengunduh episode dari situs KissAnime.com"
      echo "#           Pastikan link yang dimasukkan benar!"
      echo "#"
      echo "#           Untuk mengunduh semua episode: "
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]"
      echo "#"
      echo "#           Untuk mengunduh satu episode: "
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]/Episode-002"
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]/#2"
      echo "#"
      echo "#           Untuk mengunduh rentang episode (episode 5 hingga 10) : "
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]/#5-10"
      echo "#"
      echo "#           Untuk mengunduh episode 6 sampai akhir : "
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]/#6+"
      echo "#"
      echo "#           Untuk mengunduh episode terakhir/terbaru saja : "
      echo "#            - http://www.kissanime.com/Anime/[judul Anime]/#last"
      echo "#"
      echo "# Script akan keluar."
      cleanUp
      exit 1
   else
      curlPage "$target"
   fi
}

curlPage() {
  if [[ $2 != "quiet" ]]; then
    echo "#"
    echo "# Mengunduh halaman: $target"
  fi
  curl --compressed -A "$ua" -s "$target" > $tempFile
}

verifyPage() {
   echo "#"
   echo -n "# Memeriksa struktur halaman.."

   header=$(grep "<html" $tempFile | wc -l)
   footer=$(grep "</html>" $tempFile | wc -l)

   if [[ $header = 1 ]]; then
      if [[ $footer = 1 ]]; then
         fileStat="OK"
      else
         fileStat="KO"
      fi
   else
     fileStat="KO"
   fi

   if [[ $fileStat = "OK" ]]; then
      echo " [OK]"

      if [[ "$dlTipe" = "Anime" ]]; then
        # echo "getAnime $target"
        getAnime $target
      elif [[ "$dlTipe" = "Episode" ]]; then
        # echo "getEpisode $target"
        getEpisode $target
      else
        getAnime $target
      fi

   else
      echo ""
      echo "#"
      echo "# [-ERROR-] Struktur halaman tidak sesuai!"
      echo "#           Biasanya disebabkan karena proses mengunduh yang tidak sempurna."
      echo "#           Periksa juga koneksi internet."
      echo "#"
      echo "# Script akan keluar.."
      cleanUp
      exit 1
   fi
}

getAnime() {

   awk '/<table\>/{a=1;next}/<\/table\>/{a=0}a' $tempFile | grep "<a href=" > $tempLink
   tac $tempLink > $tempLink.tac
   rm $tempLink
   mv $tempLink.tac $tempLink

   # jika range, sesuaikan linkfile
   if [[ "$dlTipe" = "Range" ]]; then
     cat "$tempLink" | sed -n "/Episode-$epsMin/,/Episode-$epsMax/p" > "$tempLink.filter"
     rm "$tempLink"
     mv "$tempLink.filter" "$tempLink"
     rangejudul=" [Episode $epsMin-$epsMax]"
   elif [[ "$dlTipe" = "RangePlus" ]]; then
     cat "$tempLink" | awk 'p;/Episode-'$epsMin'/{p=1}' > "$tempLink.filter" # http://stackoverflow.com/a/19047354
     rm "$tempLink"
     mv "$tempLink.filter" "$tempLink"
     let epss++;
     epsjudul=$(printf "%03d" $epss)
     rangejudul=" [Episode $epsjudul+]"
   elif [[ "$dlTipe" = "Last" ]]; then
     cat "$tempLink" | tail -n1 > "$tempLink.filter" # http://stackoverflow.com/a/19047354
     rm "$tempLink"
     mv "$tempLink.filter" "$tempLink"

     target=$(cat "$tempLink" | cut -d "\"" -f2 | sed 's/?.*//g;s/^/http:\/\/proksi.ml/g')
     dlTipe="Episode"
     curlPage "$target" "quiet"
     getEpisode "$target"
     exit
   fi

   judulAnime=$(cat $tempFile | grep bigChar | head -n1 | sed 's/<[^>]\+>/ /g' | sed "s/[ \t]*//$g" | sed 's/ $//g;s/\//-/g')
   deskripsiAnime=$(cat $tempFile | awk -F: '/Summary:/ && $0 != "" { getline; print $0}')
   downloadFile="$downloadFolder/$judulAnime$rangejudul.html"

   cat $tempLink | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | sed 's/^/http:\/\/proksi.ml/g' > $linkFile
   jumlahEpisode=$(cat $tempLink | grep "<a href=" | wc -l)

   echo "# Jumlah Link Video: $jumlahEpisode"
   echo "#"
   echo "# Judul Anime: '$judulAnime$rangejudul'"

   # echo "generateLinks $target $epsMin $epsMax"
   generateLinks $target $epsMin $epsMax
}

getEpisode() {
  judulAnime=$(cat $tempFile | sed -n "/<title>/,/<\/title>/p" | sed 's/<[^>]\+>/ /g' | tr '\r\n' ' ' |  sed "s/[ \t]*//$g;s/ - *.*//g;s/\//-/g")
  # judulAnime=$(cat $tempFile | grep "itemprop=\"name\"" | sed 's/^.*content="//g' | sed 's/"\/>//g')
  downloadFile="$downloadFolder/$judulAnime.html"

  echo "#"
  echo "# Judul Episode: $judulAnime"
  echo "#"
  echo "# Mengambil link download.. "

  echo "<!-- Generated using KissAnime-DL Script by @gojigeje <gojigeje@gmail.com> on [`date +%Y-%m-%d` `date +%H:%M`] -->" > "$downloadFile"
  echo "" >> "$downloadFile"
  echo "<html><head><title>$judulAnime</title><style>div{width:75%;padding:10px;margin:0 auto;background:#D5F1FF;}.judul{background:#86D0F4;text-align:center;font-size:20px;}#deskripsi{text-align:center;}.listing{text-align:center;}.listing:hover{background:#FEFFD6;}#footer{background:#86D0F4;text-align:center;font-size:12px;}.merah{color:#FF2A2A;}</style></head><body><div class='judul'><a href='$pageurl' target='_blank'>$judulAnime</a></div>" >> "$downloadFile"

  while [[ true ]]; do
    > $tempFile
    echo -n "# - $judulAnime.."
    sleep 5
    getDlLinks $1 > $tempFile

    if [ -s "$tempFile" ]; then

      videoLink=$(cat "$tempFile")

      echo "<div class='listing'>" >> "$downloadFile"
      echo "<a href='$videoLink' target='_blank'>$judulAnime</a>" >> "$downloadFile"
      echo "</div>" >> "$downloadFile"

      echo " [OK]"
      break
    else

      echo "<div class='listing'>" >> "$downloadFile"
      echo "$judulAnime [GAGAL]" >> "$downloadFile"
      echo "</div>" >> "$downloadFile"

    fi
    # pause
    # echo "--"
    sleep 2
  done

  echo "<div id='footer'>Generated using KissAnime-DL Script by @gojigeje &lt;gojigeje@gmail.com&gt;</div>" >> "$downloadFile"
  echo "</body></html>" >> "$downloadFile"
  echo "#"
  echo "# Link video disimpan sebagai \"$downloadFile\""
  echo "#"
  echo "# [`date +%Y-%m-%d` `date +%H:%M`] - Selesai!"

  cleanUp
}

generateLinks() {
   echo "#"
   echo "# Mengambil link video.."

   echo "<!-- Generated using KissAnime-DL Script by @gojigeje <gojigeje@gmail.com> on [`date +%Y-%m-%d` `date +%H:%M`] -->" > "$downloadFile"
   echo "" >> "$downloadFile"
   echo "<html><head><title>$judulAnime$rangejudul</title><style>div{width:75%;padding:10px;margin:0 auto;background:#D5F1FF;}.judul{background:#86D0F4;text-align:center;font-size:20px;}#deskripsi{text-align:center;}.listing{text-align:center;}.listing:hover{background:#FEFFD6;}#footer{background:#86D0F4;text-align:center;font-size:12px;}.merah{color:#FF2A2A;}</style></head><body><div class='judul'><a href='$pageurl' target='_blank'>$judulAnime$rangejudul</a></div>" >> "$downloadFile"
   echo "<div id='deskripsi'>$deskripsiAnime</div>" >> "$downloadFile"

   echo "<div class='judul'>Video Link [360p]</div>" >> "$downloadFile"

   eps=$(cat $linkFile | wc -l)
   max=$(( $eps + 1 ))
   num=1
   while [[ num -lt max ]];
      do
         > $tempFile
         line="`sed -n "$num"p $linkFile`"
         judulTemp="`sed -n "$num"p $tempLink`"
         judul=$(echo $judulTemp | sed 's/^.*anime //; s/online.*$//' | sed 's/ $//g')

         # echo "getDlLinks $line > $tempFile"
         getDlLinks $line > $tempFile

         echo -n "# - $judul.."
         sleep 5

         if [ -s "$tempFile" ]; then

            videoLink=$(cat "$tempFile")

            echo "<div class='listing'>" >> "$downloadFile"
            echo "<a href='$videoLink' target='_blank'>$judul</a>" >> "$downloadFile"
            echo "</div>" >> "$downloadFile"

            echo "$videoLink" >> "$tempFile.urllist"
            echo " [OK]"

            let num++;
         else

            echo "<div class='listing'>" >> "$downloadFile"
            echo "$judul [GAGAL]" >> "$downloadFile"
            echo "</div>" >> "$downloadFile"

            continue
         fi
         # pause
         # echo "--"
         sleep 2
   done

   echo "<div id='footer'>Generated using KissAnime-DL Script by @gojigeje &lt;gojigeje@gmail.com&gt;</div>" >> "$downloadFile"
   echo "</body></html>" >> "$downloadFile"
   echo "" >> "$downloadFile"
   echo "<!-- List of video links, to be used with download manager" >> "$downloadFile"
   echo "" >> "$downloadFile"
   cat "$tempFile.urllist" >> "$downloadFile"
   echo "" >> "$downloadFile"
   echo "-->" >> "$downloadFile"

   echo "#"
   echo "# Link video disimpan sebagai \"$downloadFile\""
   echo "#"
   echo "# [`date +%Y-%m-%d` `date +%H:%M`] - Selesai!"

   cleanUp
}

getDlLinks() {
   # echo "curl -s $proxy $1 | grep \"var txha\" | cut -d \"'\" -f2 | base64 --decode"
   # decoded=$(curl -s $proxy $1 | grep "var txha" | cut -d "'" -f2 | base64 --decode)
   # python -c "import sys, urllib as ul; print ul.unquote_plus('$decoded')" | sed 's/.*|//'
   # http://unix.stackexchange.com/questions/159253 http://unix.stackexchange.com/questions/136794

   # url
   # grep id=\"selectQuality\" | sed 's/<option/\n<option/g' | sed -e 's/<option .*value=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | tail -n +2

   # quality
   # grep id=\"selectQuality\" | sed 's/<option/\n<option/g' | sed "s/<[^>]\+>/ /g;s/[ \t]*//$g" | tail -n +2

   decoded=$(curl --compressed -s $proxy $1 | grep id=\"selectQuality\" | sed 's/<option/\n<option/g' | grep 360p | sed -e 's/<option .*value=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | base64 --decode)
   echo "$decoded"
}

cleanUp() {
   rm "$tempFile" "$tempLink" "$linkFile" "$tempFile.urllist" > /dev/null 2>&1
   echo "#"
}

# cek parameter
if [ -z "$1" ]
  then
    echo " U want me to kiss what??"
    echo " $0 [url]"
    exit
  else
    mulai "$@"
fi
