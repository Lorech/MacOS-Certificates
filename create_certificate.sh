function create_certificate_authority {
    mkdir CA;
    openssl req -x509 -nodes -new -sha256 -days 397 -newkey rsa:2048 \
        -keyout "CA/certificate_authority.key" \
        -out "CA/certificate_authority.pem" \
        -subj "/CN=localhost.local/O=Local/L=Riga/ST=Riga/C=LV";
    openssl x509 -outform pem -in "CA/certificate_authority.pem" -out "CA/certificate_authority.crt";
}

while getopts ":r" opt; do
    case "$opt" in
        r) create_certificate_authority;;
    esac
done
shift $(( OPTIND - 1 ));

mkdir $1;
echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
DNS.2 = $1.local" > $1/domains.ext;

openssl req -new -nodes -newkey rsa:2048 \
    -keyout $1/certificate.key \
    -out $1/certificate.csr \
    -subj "/CN=$1.local/O=Local/L=Riga/ST=Riga/C=LV";
openssl x509 -req -sha256 -days 1024 \
    -in $1/certificate.csr \
    -CA CA/certificate_authority.pem \
    -CAkey CA/certificate_authority.key \
    -CAcreateserial \
    -extfile $1/domains.ext \
    -out $1/certificate.crt;

echo "Certificate created, you can add it to Keychain and configure Nginx.";
