// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//import "hardhat/console.sol";
import './Ticket1155Contract.sol';
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Ticket1155Factory is AccessControl {
    mapping (address => address []) public eventMap;
    address[] public deployedEvents;

    event CreatedNFT1155 (address eventAddress, address creator);

    function createEvent(
        string memory _initName
    ) external {
        address newEvent = address(new Ticket1155Contract(_initName, _msgSender()));
        eventMap[msg.sender].push(newEvent);
        deployedEvents.push(newEvent);
        emit CreatedNFT1155(newEvent, msg.sender);
    }

    function getEventByIndex (uint256 index) public view returns (address) {
        return deployedEvents[index];
    }

    function getEventByUser (address sender) public view returns (address [] memory) {
        return eventMap[sender];
    }

    function eventOfUserLength(address sender) public view returns (uint256){
        return eventMap[sender].length;
    }

    function getLengthDeployedEvents () public view returns (uint256) {
        return deployedEvents.length;
    }

}