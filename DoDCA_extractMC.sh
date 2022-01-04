#!/bin/bash
# Edited 2022.01.04
# This collects DoD Root CAs (certificates_pkcs7_WCF.zip & certificates_pkcs7_DoD.zip) to import into a mobileconfig file

latest_DOD_certs=$( curl -s https://public.cyber.mil/pki-pke/pkipke-document-library/ | grep "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip" | grep -o '".*"' | sed 's/"//g' | awk '{print $1}' )
mkdir ~/Desktop/DOD_Certs
curl -skLo ~/Desktop/DOD_Certs/latest_DOD_Certs.zip "$latest_DOD_certs"
cd ~/Desktop/DOD_Certs && unzip -qq latest_DOD_Certs.zip

# make directory for resulting certs
[[ ! -d ./DOD-CAs ]] && mkdir ./DOD-CAs && mkdir ./DOD-CAs/PEMs && mkdir ./DOD-CAs/CERs

# convert the p7b bundle to a concatenated .pem file
openssl pkcs7 -in ~/Desktop/DOD_Certs/Certificates_PKCS7_v5.9_DoD/Certificates_PKCS7_v5.9_DoD.pem.p7b -print_certs -out ./DOD-CAs/DoD_All-CAs.pem

# split .pem into separate certs
split -p "subject=" ./DOD-CAs/DoD_All-CAs.pem ./DOD-CAs/DoD_CA-

# rename each cert file to CN of cert
cd ./DOD-CAs

for f in DoD_CA-*;do 
	name=$(openssl x509 -noout -subject -in $f | sed -n '/^subject/s/^.*CN=//p')
	mv "$f" ./PEMs/"$name".pem
    ditto ./PEMs/"$name".pem ./CERs/"$name".cer
#    security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ./CERs/"$name".cer    
#	security add-trusted-cert -d -r trustAsRoot -k "/Library/Keychains/System.keychain" ./CERs/"$name".cer
done

# cleanup
#rm ./DoD_All-CAs.pem
#rm -R ~/Desktop/DOD_Certs

#echo "Folder DOD-CAs created and certificates extracted."
#open ~/Desktop

# 2 new script

latest_DODWCF_certs=$( curl -s https://public.cyber.mil/pki-pke/pkipke-document-library/ | grep "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_WCF.zip" | grep -o '".*"' | sed 's/"//g' | awk '{print $1}' )
mkdir ~/Desktop/DODWCF_Certs
curl -skLo ~/Desktop/DODWCF_Certs/latest_DODWCF_Certs.zip "$latest_DODWCF_certs"
cd ~/Desktop/DODWCF_Certs && unzip -qq latest_DODWCF_Certs.zip

# make directory for resulting certs
[[ ! -d ./DODWCF-CAs ]] && mkdir ./DODWCF-CAs && mkdir ./DODWCF-CAs/PEMs && mkdir ./DODWCF-CAs/CERs

# convert the p7b bundle to a concatenated .pem file
openssl pkcs7 -in ~/Desktop/DODWCF_Certs/Certificates_PKCS7_v5.12_WCF/Certificates_PKCS7_v5.12_WCF.pem.p7b -print_certs -out ./DODWCF-CAs/DoDWCF_All-CAs.pem

# split .pem into separate certs
split -p "subject=" ./DODWCF-CAs/DoDWCF_All-CAs.pem ./DODWCF-CAs/DoDWCF_CA-

# rename each cert file to CN of cert
cd ./DODWCF-CAs

for f in DoDWCF_CA-*;do 
	name=$(openssl x509 -noout -subject -in $f | sed -n '/^subject/s/^.*CN=//p')
	mv "$f" ./PEMs/"$name".pem
    ditto ./PEMs/"$name".pem ./CERs/"$name".cer
#	security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" ./CERs/"$name".cer    
#    security add-trusted-cert -d -r trustAsRoot -k "/Library/Keychains/System.keychain" ./CERs/"$name".cer
done

# cleanup
#rm ./DoDWCF_All-CAs.pem

#echo "Folder DODWCF-CAs created and certificates extracted."
#open ~/Desktop
#rm -R ~/Desktop/DODWCF_Certs

#kill `ps -A | grep -w Terminal.app | grep -v grep | awk '{print $1}'`