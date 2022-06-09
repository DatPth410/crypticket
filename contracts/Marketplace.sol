// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IBEP1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
}

contract Marketplace is AccessControl {
    struct Ticket1155Data {
        address _owner;
        address _ticketAddress;
        uint256 _ticketId;
        uint256 _amount;
        uint256 _price;
        uint256 _soldOut;
    }

    mapping(address => Ticket1155Data[]) private _ticket1155Data;
    address[] public listSellingEvent;

    function setSell1155Ticket(
        address ticketAddress,
        address owner,
        uint256[] memory _ticketIds,
        uint256[] memory _amounts,
        uint256[] memory _prices
    ) public {
        if (_ticket1155Data[ticketAddress].length == 0) {
            listSellingEvent.push(ticketAddress);
        }

        for (uint256 i = 0; i < _ticketIds.length; i++) {

            _ticket1155Data[ticketAddress].push(Ticket1155Data(owner ,ticketAddress, _ticketIds[i], _amounts[i], _prices[i], 0));
            IBEP1155(ticketAddress).safeTransferFrom(owner, address(this), _ticketIds[i], _amounts[i], "0x");
        }
    }

    function getLengthSellingEvent () external view returns (uint256) {
        return listSellingEvent.length;
    }

    function getTicket1155Data (address ticketAddress) external view returns (Ticket1155Data[] memory) {
        return _ticket1155Data[ticketAddress];
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}