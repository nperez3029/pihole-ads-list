#!/bin/bash

# set working dir to script dir
cd "$(dirname "$0")"

rm -f blocked.list

cat missed.list >> blocked.list
cat LG-TV-Ads.txt >> blocked.list

# Read URLs from list.list
for URL in `cat list.list`; do 
  
  # Get the last part of the URL - filename
  file_name=${URL##*/}
  [[ -z "${file_name// }" ]] && file_name=${RANDOM:0:99}

  # Check if filename has ".txt" ext; if not, add it
  if grep -q ".txt" <<< "$file_name"; then
    :
  else
    file_name="${file_name}.txt"
  fi

  # Check if there is a file already with that name. If yes, append a random number to the file_name
  if [ -e "${file_name}" ]; then
    random_num=${RANDOM:0:99}
    file_name="${file_name//.txt/}-${random_num}.txt"
  fi

  # Download the file
  echo ${URL}  ${file_name}
  curl -s ${URL} -o ${file_name} && cat ${file_name} >> blocked.list && rm -f ${file_name}
  #curl -s ${URL} -o ${file_name} && cat ${file_name} >> blocked.list
done

# Remove lines starting with "#"
# https://stackoverflow.com/questions/12272065/sed-undefined-label-on-macos
sed -i '' '/^#/ d' blocked.list 

# remove characters after '#'
sed -i '' 's/#.*$//' blocked.list

# Remove 127.0.0.1, 0.0.0.0, ::, ^ at the end of lines, ||cd . at the beginning, ^M and leading white spaces
#https://stackoverflow.com/questions/34533893/sed-command-creating-unwanted-duplicates-of-file-with-e-extension
sed -i ''  's/^127.0.0.1//' blocked.list
sed -i '' 's/^0.0.0.0//' blocked.list
sed -i '' 's/\^//' blocked.list
sed -i '' 's/^||//' blocked.list
sed -i '' 's/\r//g' blocked.list
sed -i '' "s/^[ \t]*//" blocked.list
sed -i '' '/::/d' blocked.list
  
# remove lines with html tags
# https://stackoverflow.com/questions/19878056/sed-remove-tags-from-html-file
sed -i '' 's/<*[^>]*>//g' blocked.list

# Remove duplicate lines
perl -i -ne 'print if ! $a{$_}++' blocked.list

# move youtube domains to a file - removing this as youtube ads are unblocked for now
sed -nr '/googlevideo.com/p' blocked.list > youtube.list
sed -i '' '/googlevideo.com/d' blocked.list
