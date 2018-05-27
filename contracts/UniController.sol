pragma solidity 0.4.23;

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
contract UniController is Owned {
  address private owner; //DApp

  //event sent to the DApp for new DOs e.g. University, Institute, Course, Batch, Student, Certificate are created
  event UniversityAddress(string message, address univ);
  event InstituteAddress(string message, address institute);
  event CourseAddress(string message, address course);
  event BatchAddress(string message, address batch);

  //event sent to the DApp whenever change in the internal structure e.g. Certificate added to list, Certificate granted to a student of a specific batch
  event UniversityAdded(bool flag);

  //Data Structure maintained for all the Universites over SmartChain University platform
  struct UniversityStruct {
    address univAddress;
    bool isUniversity;
	  uint index;
  }

  mapping (address => UniversityStruct) private univStructs;
  address[] private univIndex;

  //Mere Constructor
  constructor() public {
    owner = msg.sender;  // just set the self
  }

  //////////////University related methods////////////////////
  //Create University object under one name/identifier set by DApp
  function createUniversity(bytes32 _univName) public returns (address) {
	  University univ = new University(_univName);
	  addUniversity(address(univ));
	  emit UniversityAddress("New University address is :",address(univ)); //send event of address of new University to the DApp
	  return address(univ);
  }

  function isUniExist(address uniAddress) public constant returns(bool) {
    if(univIndex.length == 0) return false;
	   return ((univIndex[univStructs[uniAddress].index] == uniAddress) && (univStructs[uniAddress].isUniversity));
  }

  function getNoOfUniversity() public constant returns (uint) {
    return univIndex.length;
  }

  function getUniversityAt(uint index) public constant returns (address) {
    if(index <= univIndex.length)
      return univIndex[index];
    else
      return address(0x00);
  }

  //add university object of the local data structure
  function addUniversity(address univAddress) private returns(uint) {
    if(isUniExist(univAddress)) return uint(9999);
    univStructs[univAddress].univAddress = univAddress;
	  univStructs[univAddress].isUniversity = true;
    univStructs[univAddress].index = univIndex.push(univAddress)-1;
    emit UniversityAdded(true); //send event of address of new strudent is added to the DApp
    return univIndex.length-1;
  }

  //////////////Institute, Batch and Course creation methods////////////////////
  //Create institute object under one University with one name/identifier set by DApp
  function createInstitute(address parentUniv, bytes32 _instName) public returns (address) {
    Institute inst = new Institute(parentUniv, _instName);
	  University(parentUniv).addInstitute(address(inst));
	  emit InstituteAddress("New Institute address is :", address(inst));  //send event of address of new institute to the DApp
	  return address(inst);
  }

  //Create course object run by one institute with one name/identifier set by DApp
  function createCourse(address parentInst, bytes32 _courseIdentifier) public returns (address) {
  	Course course = new Course(parentInst, _courseIdentifier);
  	Institute(parentInst).addCourse(address(course));
	  emit CourseAddress("New Course address is :", address(course));    //send event of address of new course to the DApp
  	return address(course);
  }

  //Create batch object of a course with one name/identifier set by DApp
  function createBatch(address parentCourse, bytes32 _batchIdentifier) public returns (address) {
  	Batch batch = new Batch(parentCourse, _batchIdentifier);
  	Course(parentCourse).addBatch(address(batch));
    //string constant msg  = "New Batch is created :";
    emit BatchAddress("New Batch address is :", address(batch));  //send event of address of new batch to the DApp
  	return address(batch);
  }

  //Important method as part of verification, to check if this quadruple belongs to the same hierarchy or not!!
  function checkHierarchy(address univAddress,address instAddress,address courseAddress,address batchAddress) public constant returns (bool) {
    if(!isUniExist(univAddress)) return false;

  	University univ = University(univAddress);
  	if(!univ.isInstituteExist(instAddress)) return false;

  	Institute inst = Institute(instAddress);
  	if(!inst.isCourseExist(courseAddress)) return false;

  	Course course = Course(courseAddress);
  	if(!course.isBatchExist(batchAddress)) return false;

  	return true;
  }

  //Another important method of verification process, whether merkel root of the associated batch, of the given certificate is same as the sent by the student!!
  function verifyMerketRoot(address certAddress, bytes32 merkelRootHash) public constant returns(bool) {
    Certificate cert = Certificate(certAddress);
    address batchAddress = cert.getBatchAddress();
    Batch batch = Batch(batchAddress);
  	return (batch.getMerkelRoot() == merkelRootHash);
  }

  //The method to set merkel root hash of the entire batch once all the student will be granted certificates!!
  function setMerketRoot(address batchAddress, bytes32 merkelRoot) public returns(bool) {
    Batch batch = Batch(batchAddress);
    return batch.setMerkelRoot(merkelRoot);
  }
}
