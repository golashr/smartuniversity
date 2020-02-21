//pragma solidity 0.4.23;
pragma solidity >=0.5.0 <0.7.0;

import "./Owned.sol";
import "./Student.sol";
import "./Certificate.sol";
import "./University.sol";
import "./Institute.sol";
import "./Course.sol";
import "./Batch.sol";
import "./ConvertLib.sol";

//Main controlling class, Facade pattern which controls the Create, Read and Update operations on Domain Objects e.g.
//a. different universities;
//b. different Institutes under the same University;
//c. different courses provided by the given Institute,
//d. different batches related to each course as per their duration and year;
//e. list of Students studying a courses for a specific batch
//f. Certificate which is created first and later granted to a student once course is successfully completed.
contract CertController is Owned {
  address private owner; //DApp

  //event sent to the DApp for new DOs e.g. University, Institute, Course, Batch, Student, Certificate are created
  event StudentAddress(address student);
  event CertificateAddress(address certificate, address batchAddr);
  event VerifyCertificate(address stuAddress, string message, address batchAddress);

  //event sent to the DApp whenever change in the internal structure e.g. Certificate added to list, Certificate granted to a student of a specific batch
  event StudentAdded(bool flag);
  event CertificateAdded(bool flag);
  event CertificateGranted(address batchAddress, address stuAddress, address certAddress, bool flag);

  //Data Structure maintained for Certificates, issued by SmartChain University platform
  struct CertificateStruct {
    address certificateAddress;
	  bool isCertificate;
	  uint index;
  }

  mapping (address => CertificateStruct) private certificateStructs;
  address[] private certificateIndex;

  //Data Structure maintained for all Students over SmartChain University platform
  struct StudentStruct {
    address studentAddress;
	  bool isStudent;
	  uint index;
  }

  mapping (address => StudentStruct) private studentStructs;
  address[] private studentIndex;

  //Mere Constructor
  constructor() public {
    owner = msg.sender;  // just set the self
  }

  //////////////Certificate related methods////////////////////
  //Create certificate object of a batch with one name/identifier with two flags set by DApp
  function createCertificate(address batchAddr, bytes32 _certIdentifier, bool _revoke, bool _expired) public returns (address) {
  	Certificate cert = new Certificate(batchAddr, _certIdentifier, _revoke, _expired);
  	addCertificate(address(cert));
  	emit CertificateAddress(address(cert), batchAddr);  //send event of address of new certificate to the DApp
	  return address(cert);
  }

  function isCertificateExist(address certAddress) public view returns(bool) {
     if(certificateIndex.length == 0) return false;
	    return ((certificateIndex[certificateStructs[certAddress].index] == certAddress) && (certificateStructs[certAddress].isCertificate));
  }

  function getNoOfCertificates() public view returns (uint) {
    return certificateIndex.length;
  }

  function getCertificateAt(uint index) public view returns (address) {
    if(index <= certificateIndex.length)
      return certificateIndex[index];
    else
      return address(0x00);
  }

  //add certificate object of the local data structure
  function addCertificate(address certificateAddress) private returns(uint) {
    if(isCertificateExist(certificateAddress)) return uint(9999);
    certificateStructs[certificateAddress].certificateAddress = certificateAddress;
	  certificateStructs[certificateAddress].isCertificate = true;
    certificateStructs[certificateAddress].index = certificateIndex.push(certificateAddress)-1;
    emit CertificateAdded(true);  //send event the new course is added to the DApp
    return certificateIndex.length-1;
  }

  //////////////Certificate related methods////////////////////
  //Create student object of a batch with one name/identifier set by DApp
  function addNewStudent(address batchAddress, bytes32 _studentIdentifier) public returns (address) {
    Student student = new Student(_studentIdentifier);

    address studAddress = address(student);
    addStudent(studAddress);

    Batch batch = Batch(batchAddress);
    batch.addStudent(studAddress); //To set with Batch

    emit StudentAddress(studAddress); //send event of address of new student to the DApp
    return studAddress;
  }

  function isStudentExist(address studAddress) public view returns(bool) {
     if(studentIndex.length == 0) return false;
	    return ((studentIndex[studentStructs[studAddress].index] == studAddress) && (studentStructs[studAddress].isStudent));
  }

  function getNoOfStudents() public view returns (uint) {
    return studentIndex.length;
  }

  function getStudentAt(uint index) public view returns (address) {
    if(index <= studentIndex.length)
      return studentIndex[index];
    else
      return address(0x00);
  }

  //add student object of the local data structure
  function addStudent(address studentAddress) private returns(uint) {
    if(isStudentExist(studentAddress)) return uint(9999);
    studentStructs[studentAddress].studentAddress = studentAddress;
	  studentStructs[studentAddress].isStudent = true;
    studentStructs[studentAddress].index = studentIndex.push(studentAddress)-1;
    emit StudentAdded(true);  //send event of address of new strudent is added to the DApp
    return studentIndex.length-1;
  }

  //////////////Business logic starts from here////////////////////
  //add certificate to the list if it does not exists already. With this, certificate is granted to the student
  function issueCertificate(address batchAddress, address studAddress, address certAddress, bytes32 timestamp) public returns(bool) {
    //Actually granting the certificate
    Student student = Student(studAddress);
    bool flag = student.grantCertificate(batchAddress, certAddress, timestamp);
    emit CertificateGranted(batchAddress,studAddress,certAddress,flag);
    return flag;
  }

  //The method to set hash of the cert when the given certificate is granted to the given student!!
  function setCertHash(address certAddress, bytes32 certHash) public returns(bool) {
    Certificate cert = Certificate(certAddress);
    return cert.setCertHash(certHash);
  }

  //The most important method to verify whether the given certificate is granted to the given student or not!!
  function verifyCertificate(address studAddress, address certAddress) public returns(bool) {
    Certificate cert = Certificate(certAddress);
    address batchAddress = cert.getBatchAddress();
    emit VerifyCertificate(studAddress, "Certificate is associated with Batch :", batchAddress);
    Batch batch = Batch(batchAddress);
  	if(!batch.isStudentExist(studAddress)) return false;

   	Student student = Student(studAddress);
  	if(!student.isCertGranted(certAddress)) return false;
          return true;
  }

  //Another important method of verification process, whether hash of the given certificate is same as of the sent by the student!!
  function verifyCertHash(address certAddress, bytes32 certHash) public view returns(bool) {
    Certificate cert = Certificate(certAddress);
    return (cert.getCertHash() == certHash);
  }
}
