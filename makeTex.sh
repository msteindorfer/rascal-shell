export csvFile=$1
export resultFile=$2

rm "$resultFile"
echo "% !TEX encoding = UTF-8 Unicode" >> "$resultFile"
echo "% !TEX root = ../paper.tex" >> "$resultFile"
echo "" >> "$resultFile"

find . -name "$csvFile" -exec tail -1 {} \; | sort | awk '{ print $0 " \\\\ \\hline" }' >> "$resultFile"
