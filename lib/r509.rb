# A module for building an easy to use CA. Includes CSR, Certificate, and CRL support.
module R509
    autoload :CertificateAuthority, 'r509/CertificateAuthority.rb'
    autoload :Csr, 'r509/Csr.rb'
    autoload :Spki, 'r509/Spki.rb'
    autoload :Cert, 'r509/Cert.rb'
    autoload :Crl, 'r509/Crl.rb'
    autoload :OidMapper, 'r509/OidMapper.rb'
    autoload :Ocsp, 'r509/Ocsp.rb'
    autoload :Config, 'r509/Config.rb'
    autoload :PrivateKey, 'r509/PrivateKey.rb'
    autoload :MessageDigest, 'r509/MessageDigest.rb'
    autoload :Subject, 'r509/Subject.rb'
    autoload :Validity, 'r509/Validity.rb'
end

#add some global mappings we want available throughout r509
R509::OidMapper.batch_register([
    { :oid => "2.5.4.15", :short_name => "businessCategory" },
    { :oid => "1.3.6.1.4.1.311.60.2.1.2", :short_name => "jurisdictionOfIncorporationStateOrProvinceName" },
    { :oid => "1.3.6.1.4.1.311.60.2.1.3", :short_name => "jurisdictionOfIncorporationCountryName" }
])
