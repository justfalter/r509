require 'spec_helper'
require 'r509/PrivateKey'
require 'stringio'

describe R509::PrivateKey do
    before :all do
        @key_csr = TestFixtures::KEY_CSR
        @key_csr_encrypted = TestFixtures::KEY_CSR_ENCRYPTED
        @csr_public_key_modulus = TestFixtures::CSR_PUBLIC_KEY_MODULUS
        @key_csr_der = TestFixtures::KEY_CSR_DER
        @dsa_key = TestFixtures::DSA_KEY
    end
    it "throws an exception when given a type other than DSA or RSA" do
        expect { R509::PrivateKey.new(:type=>:not_rsa_or_dsa) }.to raise_error(ArgumentError)
    end
    it "throws an exception when no hash is provided" do
        expect { R509::PrivateKey.new('string') }.to raise_error(ArgumentError,'Must provide a hash of options')
    end
    it "defaults to RSA" do
        private_key = R509::PrivateKey.new(:bit_strength=>1024)
        private_key.type.should == :rsa
        private_key.key.kind_of?(OpenSSL::PKey::RSA).should == true
    end
    it "loads a pre-existing RSA key" do
        private_key = R509::PrivateKey.new(:key=>@key_csr)
        private_key.to_pem.should == @key_csr
        @key_csr.should_not == nil
    end
    it "generates an RSA key at the default bit strength (2048)" do
        private_key = R509::PrivateKey.new(:type => :rsa)
        private_key.bit_strength.should == 2048
        private_key.key.n.to_i.to_s(2).size.should == 2048
    end
    it "generates an RSA key at a custom bit strength" do
        private_key = R509::PrivateKey.new(:type => :rsa, :bit_strength => 512)
        private_key.bit_strength.should == 512
        private_key.key.n.to_i.to_s(2).size.should == 512
    end
    it "loads a pre-existing DSA key" do
        private_key = R509::PrivateKey.new(:key => @dsa_key, :type => :dsa)
        private_key.key.to_pem.should == @dsa_key
        @dsa_key.should_not == nil
    end
    it "generates a DSA key at the default bit strength (2048)" do
        private_key = R509::PrivateKey.new(:type => :dsa)
        private_key.bit_strength.should == 2048
        private_key.key.p.to_i.to_s(2).size.should == 2048
    end
    it "generates a RSA key at a custom bit strength" do
        private_key = R509::PrivateKey.new(:type => :dsa, :bit_strength => 512)
        private_key.bit_strength.should == 512
        private_key.key.p.to_i.to_s(2).size.should == 512
    end
    it "has an exponent of 65537 for new RSA keys" do
        #this test actually checks ruby's underlying libs to make sure they're
        #doing what they're supposed to be doing.
        private_key = R509::PrivateKey.new(:type => :rsa, :bit_strength => 512)
        private_key.key.e.should == 65537
    end
    it "returns the public key" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        private_key.public_key.n.to_i.should == @csr_public_key_modulus.to_i
    end
    it "returns pem" do
        #load the DER, check that it matches the PEM on to_pem
        private_key = R509::PrivateKey.new(:key => @key_csr_der)
        private_key.to_pem.should == @key_csr
    end
    it "returns der" do
        #load the PEM, check that it matches the DER on to_der
        private_key = R509::PrivateKey.new(:key => @key_csr)
        private_key.to_der.should == @key_csr_der
    end
    it "writes pem" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        sio = StringIO.new
        sio.set_encoding("BINARY") if sio.respond_to?(:set_encoding)
        private_key.write_pem(sio)
        sio.string.should == @key_csr
    end
    it "writes der" do
        private_key = R509::PrivateKey.new(:key => @key_csr_der)
        sio = StringIO.new
        sio.set_encoding("BINARY") if sio.respond_to?(:set_encoding)
        private_key.write_der(sio)
        sio.string.should == @key_csr_der
    end
    it "loads an encrypted private key with the right password" do
        private_key = R509::PrivateKey.new(:key => @key_csr_encrypted, :password => 'Testing1')
        private_key.public_key.n.to_i.should == @csr_public_key_modulus.to_i
    end
    it "fails to load an encrypted private key with wrong password" do
        expect { R509::PrivateKey.new(:key => @key_csr_encrypted, :password => 'wrongPassword') }.to raise_error(R509::R509Error,"Failed to load private key. Invalid key or incorrect password.")
    end
    it "returns an encrypted pem" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        encrypted_private_key = private_key.to_encrypted_pem('des3','Testing1')
        decrypted_private_key = R509::PrivateKey.new(:key => encrypted_private_key, :password => 'Testing1')
        private_key.to_pem.should == decrypted_private_key.to_pem
    end
    it "writes an encrypted pem" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        sio = StringIO.new
        sio.set_encoding("BINARY") if sio.respond_to?(:set_encoding)
        private_key.write_encrypted_pem(sio,'des3','Testing1')
        sio.string.match(/Proc-Type: 4,ENCRYPTED/).should_not == nil
    end
    it "creates an encrypted private key with des3 cipher" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        sio = StringIO.new
        sio.set_encoding("BINARY") if sio.respond_to?(:set_encoding)
        private_key.write_encrypted_pem(sio,'des3','Testing1')
        sio.string.match(/DES-EDE3-CBC/).should_not == nil
    end
    it "creates an encrypted private key with aes128 cipher" do
        private_key = R509::PrivateKey.new(:key => @key_csr)
        sio = StringIO.new
        sio.set_encoding("BINARY") if sio.respond_to?(:set_encoding)
        private_key.write_encrypted_pem(sio,'aes128','Testing1')
        sio.string.match(/AES-128-CBC/).should_not == nil
    end
end
