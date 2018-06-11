FROM kvaps/fio
ADD massfio_parse.sh massfio.sh /
ENTRYPOINT [ "massfio.sh" ]
