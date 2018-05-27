pragma solidity 0.4.23;

import "./Owned.sol";

//Certificate domain object which is to depict a certificate state in Blockchain
contract Certificate is Owned{
  bytes32 private certIdentifier; //Unique indetifier, to be given by DApp
  bool private isRevokedFlag;     //whether certificate is revoked by uni due to any reason
  bool private isExpiredFlag;     //whether certificate is expired or still active
  address private owner;      		//Address of ControllerContract
  address private addressStudent; //Address of Student to whom the certificate is granted
  address private addressBatch;   //Address of Batch to whom the owner Student is part of
  bytes32 private certHash;       //Hash of the certificate saved with DApp by SHA256notaryHash
  bytes32 private issuedOn;       //the timestamp string set by the DApp of which cert is issued to the student

  //event sent to the DApp when new certificate is granted
  event CertGrantedCert(bool flag);

  //Constructor of the certificate object, address of parent batch and cert identifier is sent, two flags
  constructor(address batchAddress, bytes32 _certIdentifier, bool _revoke, bool _expired) public {
    owner = msg.sender;  // just set the ControllerContract
    certIdentifier = _certIdentifier;
    addressStudent = address(0x00); //iniialize with null value, really needed?
	  addressBatch = batchAddress;
    isRevokedFlag = _revoke;
    isExpiredFlag = _expired;
  }

  //For CertIdentifier
  function getCertIdentifier() public constant returns(bytes32) {
      return certIdentifier;
  }

  //For Revocation
  function isRevoked() public constant returns(bool) {
      return isRevokedFlag;
  }

  //revoke the certificate, done from the DApp
  function revokeCert() onlyOwner public returns(bool) {
      isRevokedFlag = true;
      return true;
  }

  //Re-invoke the certificate, done from the DApp
  function suspendRevocation() onlyOwner public returns(bool) {
      isRevokedFlag = false;
      return true;
  }

  //For Expiry
  function isExpired() public constant returns(bool) {
      return isExpiredFlag;
  }

  //expire the certificate, done from the DApp
  function expireCert() onlyOwner public returns(bool) {
      isExpiredFlag = true;
      return true;
  }

  //here, certificate is associated with a specific student
  function grantCertificate(address studentAddress, bytes32 timestamp) onlyOwner public returns(bool) {
      addressStudent = studentAddress;
      issuedOn = timestamp;
      emit CertGrantedCert(true);
      return true;
  }

  //For BatchAddress
  function getBatchAddress() public constant returns(address) {
      return addressBatch;
  }

  //For student
  function getGrantedStudent() public constant returns(address) {
      return addressStudent;
  }

  //For cert Hash
  function getCertHash() public constant returns(bytes32) {
      return certHash;
  }

  function setCertHash(bytes32 _certHash) public returns(bool) {
    certHash = _certHash;
  }
}
