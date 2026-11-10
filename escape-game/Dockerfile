# Escape game Docker.
# Ne lis pas ce fichier pour trouver les réponses : elles sont encodées.
# Lance le jeu avec les commandes de LANCER.md.
FROM alpine:3.22

ENV INDICE="Le morceau 2 est encodé. Pour le lire : docker exec escape decoder MORCEAU_2"
ENV MORCEAU_2="CiAgTU9SQ0VBVSAyIDogSFVCTE9UCgpCaWVuIGpvdcOpLiBMZSBtb3JjZWF1IDMgZXN0IHVuIGZpY2hpZXIgZGFucyBsZSBkb3NzaWVyIC9jYWNoZXR0ZQpkdSBjb250ZW5ldXIuIE1haXMgYXR0ZW50aW9uIDogYydlc3QgdW4gZmljaGllciBDQUNIw4kuIFNvdXMgTGludXgsCnVuIGZpY2hpZXIgY2FjaMOpIGNvbW1lbmNlIHBhciB1biBwb2ludCwgZXQgbHMgbmUgbGUgbW9udHJlIHBhcwpzYW5zIGwnb3B0aW9uIC1hLgoKQmxvcXXDqSA/IE91dnJlIGVzY2FwZS1nYW1lL2luZGljZXMvZXRhcGUtMy50eHQK"

COPY partie.sh /jeu/partie.sh
COPY decoder.sh /usr/local/bin/decoder
RUN sed -i "s/\r$//" /jeu/partie.sh /usr/local/bin/decoder && chmod +x /jeu/partie.sh /usr/local/bin/decoder

ENTRYPOINT ["/jeu/partie.sh"]
