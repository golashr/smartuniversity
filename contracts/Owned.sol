//pragma solidity 0.4.23;
pragma solidity >=0.5.0 <0.7.0;

contract Owned {
  address payable private owner;     //Address of ControllerContract

  constructor() public {
     owner = msg.sender; // just set the ControllerContract
  }

  modifier onlyOwner {
  	require(msg.sender == owner);
  	_;
  }

  function kill() internal onlyOwner {
    selfdestruct(owner);
  }
}
