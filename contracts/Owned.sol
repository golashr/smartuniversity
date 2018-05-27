pragma solidity 0.4.23;

contract Owned {
  address private owner;     //Address of ControllerContract

  constructor() public {
     owner = msg.sender; // just set the ControllerContract
  }

  modifier onlyOwner {
  	require(msg.sender == owner);
  	_;
  }

  function kill() onlyOwner internal {
    selfdestruct(owner);
  }
}
