//pragma solidity 0.4.23;
pragma solidity >=0.5.0 <0.7.0;

import "./Owned.sol";

//University domain object which is to depict an University state in Blockchain
contract University is Owned{
  address private owner;      				   //Address of ControllerContract
  bytes32 private universityIdentifier;  //identifier String of University, set from the DApp

  //event sent to the DApp when new institute is added to the University
  event InstituteAdded(bool flag);

  //Data Structure maintained for Institutes
  struct InstituteStruct {
    address instituteData;
    bool isInstitute;
    uint index;
  }
  mapping (address => InstituteStruct) private instituteStructs;
  address[] private instituteIndex;

  //Constructor of the University object
  constructor(bytes32 _univIdentifier) public {
    owner = msg.sender;  	// just set the ControllerContract
    universityIdentifier = _univIdentifier;
  }

  //Get universityIdentifier
  function getUnivesityIdentifier() public view returns(bytes32) {
      return universityIdentifier;
  }

  //Check whether Institute already exists
  function isInstituteExist(address instituteAddress) public view returns(bool) {
  	if(instituteIndex.length == 0) return false;
  	return ((instituteIndex[instituteStructs[instituteAddress].index] == instituteAddress) && (instituteStructs[instituteAddress].isInstitute));
  }

  //Get the institute at the given index
  function getInstituteAt(uint index) public view returns(address) {
    if(index < instituteIndex.length)
      return instituteIndex[index];
    else
      return address(0x00); //return null value in the case of index invalid
  }

  //add institute to the list if it does not exists already
  function addInstitute(address instituteAddress) public onlyOwner returns(uint) {
    if(isInstituteExist(instituteAddress)) return uint(9999); //9999 is merely a number sent to the callee, signifying the given Institute already exists
    instituteStructs[instituteAddress].instituteData = instituteAddress;
	  instituteStructs[instituteAddress].isInstitute = true;
    instituteStructs[instituteAddress].index = instituteIndex.push(instituteAddress)-1;
    emit InstituteAdded(true);
    return instituteIndex.length-1;
  }
}
