pragma solidity 0.4.23;

import "./Certificate.sol";
import "./Owned.sol";

//Student domain object which is to depict a student state in Blockchain
contract Student is Owned{
  address private owner;      				//Address of ControllerContract
  address private batchAddress;       //Address of Batch, which student is part of!
  bytes32 private studentIdentifier;  //student identifier, sent by DApp

  //event sent to the DApp when new certificate is granted to the student
  //event CertGranted(bool flag);

  //Data Structure maintained for Certificates
  struct CertStruct {
      address certificateAddress;
	    bool isCertificateGranted;
	    uint index;
  }
  mapping (address => CertStruct) private certStructs;
  address[] private certIndex;

  //Constructor of the student object, student identifier is sent
  constructor(bytes32 _studentIdentifier) public {
    owner = msg.sender;  // just set the ControllerContract
    studentIdentifier = _studentIdentifier;
  }

  //Check whether Certificate already granted
  function isCertGranted(address certAddress) public constant returns(bool) {
    if(certIndex.length == 0) return false;
	  return ((certIndex[certStructs[certAddress].index] == certAddress) && (certStructs[certAddress].isCertificateGranted));
  }

  //add certificate to the list if it does not exists already. With this, certificate is granted to the student
  function grantCertificate(address _batchAddress, address certAddress, bytes32 timestamp) onlyOwner public returns(bool) {
    if(isCertGranted(certAddress)) return true;

    //assign the timestamp
    Certificate cert = Certificate(certAddress);
    cert.grantCertificate(this, timestamp);

    certStructs[certAddress].certificateAddress = certAddress;
	  certStructs[certAddress].isCertificateGranted = true;
    certStructs[certAddress].index = certIndex.push(certAddress)-1;

    batchAddress = _batchAddress;
    return true;
  }

  //get parent batch address
  function getBatchAddress() public constant returns (address) {
  	return batchAddress;
  }

  //Check whether Student already exists
  function getCertificateAt(uint index) public constant returns (address) {
  	if(index < certIndex.length)
  		return certIndex[index];
  	else
  		return address(0x00); //return null value in the case of index invalid
  }

  //Check whether Student already exists
  function getNoOfCertificates() public constant returns (uint) {
    return certIndex.length;
  }

  //Currently, there is no standard support from solidity to pass dynamic aray as input parameter! Assuming that no of certificates will not be more than 20
  function getAllCertificate() public constant returns(address[20]) {
     address[20] memory certificatesArray;
     for (uint index = 0; index < certIndex.length; index++) {
		if(certStructs[certIndex[index]].isCertificateGranted) //If flag is true
        certificatesArray[index] = certStructs[certIndex[index]].certificateAddress;
     }
     return certificatesArray;
  }
}
