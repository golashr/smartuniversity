//pragma solidity 0.5.23;
pragma solidity >=0.5.0 <0.7.0;

import "./Student.sol";
import "./Owned.sol";

//Batch domain object, related to a course which is to depict a batch object in Blockchain
contract Batch is Owned{
  address private owner;      		  //Address of ControllerContract
  address private addressCourse;    //Address of parent Course
  bytes32 private batchIdentifier;  //Unique indetifier of Batch, set from the DApp
  bytes32 private merkelRootHash;   //This is merkel root of all the certs issued, by SHA256notaryHash

  //event sent when new student is added
  event StudentAdded(bool flag);

  //Data Structure maintained for Students
  struct StudentStruct {
    address studentData;
    bool isStudent;
	  uint index;
  }
  mapping (address => StudentStruct) private studentStructs;
  address[] private studentIndex;

  //Constructor of the batch object, address of parent Course and batch identifier is sent
  constructor(address _addressCourse, bytes32 _batchIdentifier) public {
    owner = msg.sender;  // just set the ControllerContract
    addressCourse = _addressCourse;
    batchIdentifier = _batchIdentifier;
  }

  //For batchIdentifier
  function getBatchIdentifier() public view returns(bytes32) {
      return batchIdentifier;
  }

  //For CourseAddress
  function getCourseAddress() public view returns(address) {
      return addressCourse;
  }

  //Check whether Student already exists
  function isStudentExist(address studAddress) public view returns(bool) {
    if(studentIndex.length == 0) return false;
	    return ((studentIndex[studentStructs[studAddress].index] == studAddress) && (studentStructs[studAddress].isStudent));
  }

  //add the new student to the list, if it does not exists already
  function addStudent(address studAddress) public onlyOwner returns(uint) {
    if(isStudentExist(studAddress)) return uint(9999); //9999 is merely a number sent to the callee, signifying the given student already part of the batch
    studentStructs[studAddress].studentData = studAddress;
	  studentStructs[studAddress].isStudent = true;
    studentStructs[studAddress].index = studentIndex.push(studAddress)-1;
    emit StudentAdded(true);
    return studentIndex.length-1;
  }

  //get the total no of students of the batch
  function getNoOfStudents() public view returns (uint) {
    return studentIndex.length;
  }

  function getStudentAt(uint index) public view returns (address) {
  	if(index < studentIndex.length)
  		return studentIndex[index];
  	else
  		return address(0x00);
  }

  //Currently, there is no standard support from solidity to pass dynamic aray as input parameter! Assuming that no of students will not be more than 20
  function getAllStudents() public view returns(address[20] memory) {
    address[20] memory studentsArray;
    for (uint index = 0; index < studentIndex.length; index++) {
  	if(studentStructs[studentIndex[index]].isStudent) //If flag is true
      studentsArray[index] = studentStructs[studentIndex[index]].studentData;
    }
    return studentsArray;
  }

  //Get Merkel root of the batch associated with all the certificates assigned for all successful student under the batch
  function getMerkelRoot() public view returns(bytes32) {
    return merkelRootHash;
  }

  //Set Merkel root of all the certificates assigned for all successful student under the batch
  function setMerkelRoot(bytes32 _merkelRootHash) public returns(bool) {
    merkelRootHash = _merkelRootHash;
    return true;
  }
}
