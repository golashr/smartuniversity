pragma solidity 0.4.23;

import "./Batch.sol";
import "./Owned.sol";

//Course domain object which is to depict a course state in Blockchain
contract Course is Owned{
  address private owner;      				//Address of ControllerContract
  address private addressInstitute;   //Address of Institute
  bytes32 private courseIdentifier;   //Unique indetifier, to be given by DApp

  //event sent to the DApp when new Batch is added to the course
  event BatchAdded(bool flag);

  //Data Structure maintained for batches of the given course
  struct BatchStruct {
    address batchData;
    bool isBatch;
	  uint index;
  }
  mapping (address => BatchStruct) private batchStructs;
  address[] private batchIndex;

  //Constructor of the course object, address of parent institute and course identifier is sent
  constructor(address _addressInstitute, bytes32 _courseIdentifier) public {
    owner = msg.sender;  // just set the ControllerContract
    courseIdentifier = _courseIdentifier;
    addressInstitute = _addressInstitute;
  }

  //For courseIdentifier
  function getCourseIdentifier() public constant returns(bytes32) {
      return courseIdentifier;
  }

  //For addressInstitute
  function getInstituteAddress() public constant returns(address) {
      return addressInstitute;
  }

  //Check whether Batch already exists
  function isBatchExist(address batchAddress) public constant returns(bool) {
    if(batchIndex.length == 0) return false;
	    return ((batchIndex[batchStructs[batchAddress].index] == batchAddress) && (batchStructs[batchAddress].isBatch));
  }

  //add the new batch to the list, if it does not exists already
  function addBatch(address batchAddress) onlyOwner public returns(uint) {
    if(isBatchExist(batchAddress)) return uint(9999); //9999 is merely a number sent to the callee, signifying the given batch of the course already exists
    batchStructs[batchAddress].batchData = batchAddress;
	  batchStructs[batchAddress].isBatch = true;
    batchStructs[batchAddress].index = batchIndex.push(batchAddress)-1;
    emit BatchAdded(true);
    return batchIndex.length-1;
  }

  //Get the number of batches under the course
  function getNoOfBatches() public constant returns (uint) {
    return batchIndex.length;
  }

  //Get the batch address against the index
  function getBatchAt(uint index) public constant returns (address) {
  	if(index < batchIndex.length)
  		return batchIndex[index];
  	else
  		return address(0x00); //return null value in the case of index invalid
  }

  //Currently, there is no standard support from solidity to pass dynamic aray as input parameter! Assuming that no of batches will not be more than 20
  function getAllBatches() public constant returns(address[20]) {
    address[20] memory batchesArray;
    for (uint index = 0; index < batchIndex.length; index++) {
    if(batchStructs[batchIndex[index]].isBatch) //If flag is true
      batchesArray[index] = batchStructs[batchIndex[index]].batchData;
    }
    return batchesArray;
  }
}
