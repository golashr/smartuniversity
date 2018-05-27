pragma solidity 0.4.23;

import "./Course.sol";
import "./Owned.sol";

//Institute domain object which is to depict an institute state in Blockchain
contract Institute is Owned{
  address private owner;      		      //Address of ControllerContract
  address private addressUniversity;    //Address of University
  bytes32 private instituteIdentifier;  //identifier String of Institute, set from the DApp

  //event sent to the DApp when new Course is added to the Institute
  event CourseAdded(bool flag);

  //Data Structure maintained for Courses run by Institute
  struct courseStruct {
      address courseAddress;
      bool isCourse;
      uint index;
  }
  mapping (address => courseStruct) private courseStructs;
  address[] private courseIndex;

  //Constructor of the institute object, address of parent University and institute identifier is sent
  constructor(address _addressUniversity, bytes32 _instituteIdentifier) public {
    owner = msg.sender;  // just set the self
    addressUniversity = _addressUniversity;
    instituteIdentifier = _instituteIdentifier;
  }

  //For addressUniversity
  function getAddressUniversity() public constant returns(address) {
      return addressUniversity;
  }

  //For courseIdentifier
  function getInstituteIdentifier() public constant returns(bytes32) {
      return instituteIdentifier;
  }

  //Check whether Course already exists
  function isCourseExist(address courseAddress) public constant returns(bool isIndeed) {
    if(courseIndex.length == 0) return false;
     return ((courseIndex[courseStructs[courseAddress].index] == courseAddress) && (courseStructs[courseAddress].isCourse));
  }

  //add the new course to the list, if it does not exists already
  function addCourse(address courseAddress) onlyOwner public returns(uint) {
      if(isCourseExist(courseAddress)) return uint(9999); //9999 is merely a number sent to the callee, signifying the given course already exists
      courseStructs[courseAddress].courseAddress = courseAddress;
      courseStructs[courseAddress].isCourse = true;
      courseStructs[courseAddress].index = courseIndex.push(courseAddress)-1;
      emit CourseAdded(true);
      return courseIndex.length-1;
  }

  //Get the total no of courses
  function getNoOfCourses() public constant returns (uint) {
    return courseIndex.length;
  }

  //Get the Course at the given index
  function getCourseAt(uint index) public constant returns (address) {
  	if(index < courseIndex.length)
  		return courseIndex[index];
  	else
  		return address(0x00); //return null value in the case of invalid index
  }

  //Currently, there is no standard practice to pass dynamic aray as input parameter! Assuming that no of courses will not be more than 25
  function getAllCourses() public constant returns(address[25]) {
    address[25] memory coursesArray;
    for (uint index = 0; index < courseIndex.length; index++) {
    if(courseStructs[courseIndex[index]].isCourse) //If flag is true
      coursesArray[index] = courseStructs[courseIndex[index]].courseAddress;
    }
    return coursesArray;
  }
}
