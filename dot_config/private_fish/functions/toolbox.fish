function toolbox -d "Shell tricks and one-liners"

set desc 'Shrink a PDF file using Ghostscript'
set cmd 'gs -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS=/screen \
    -dNOPAUSE -dQUIET -dBATCH \
    -sOutputFile="output.pdf" \
    "input.pdf"'
echo -e "# $desc\n$cmd\n"

set desc 'Shrink a PDF with magick'
set cmd 'magick -density 150 input.pdf -resize 50% -quality 85 -compress jpeg output.pdf'
echo -e "# $desc\n$cmd\n"

set desc 'Merge images into a PDF'
set cmd 'magick *.HEIC -compress jpeg -quality 75 -colorspace Gray -resize 60% output.pdf'
echo -e "# $desc\n$cmd\n"

set desc 'Compress images'
set cmd 'mogrify -format jpg -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB *.png'
echo -e "# $desc\n$cmd\n"

set desc 'Get Mac app bunde id'
set cmd 'osascript -e \'id of app "MyApp"\''
echo -e "# $desc\n$cmd\n"

end
