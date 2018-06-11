FROM kvaps/fio
RUN apt-get update \
 && apt-get -y install bash \
 && apt-get clean
ADD massfio_parse.sh massfio.sh /
