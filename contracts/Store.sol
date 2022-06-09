// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IBEP1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function getPriceTicket(uint256 _id) external view returns (uint256);
}

contract Store is AccessControl {
    uint256 public constant OWNER_RATE = 6;
    uint256 public constant PRICE_RANGE = 15;

    event sellTicketEventStore (address ticketAddress, uint256 ticketId, uint256 amount, uint256 price);

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
        require(_checkValidTicketPrice(ticketAddress, _ticketIds, _prices), "Price is not valid!");

        if (_ticket1155Data[ticketAddress].length == 0) {
            listSellingEvent.push(ticketAddress);
        }

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            _ticket1155Data[ticketAddress].push(Ticket1155Data(owner ,ticketAddress, _ticketIds[i], _amounts[i], _prices[i], 0));
            IBEP1155(ticketAddress).safeTransferFrom(owner, address(this), _ticketIds[i], _amounts[i], "0x");
            emit sellTicketEventStore(ticketAddress, _ticketIds[i], _amounts[i], _prices[i]);
        }
    }

    function _checkValidTicketPrice (
        address ticketAddress,
        uint256[] memory _ticketIds,
        uint256[] memory _prices
    ) internal view returns (bool){
        for (uint256 i = 0; i < _ticketIds.length; i++) {
            if (
                _prices[i] > _getTicketPricebyId(ticketAddress, _ticketIds[i])*(100+PRICE_RANGE)/100 ||
                _prices[i] < _getTicketPricebyId(ticketAddress, _ticketIds[i])*(100-PRICE_RANGE)/100
            ) return false;
        }
        return true;
    }

    function _getTicketPricebyId(address ticketAddress, uint256 ticketId) internal view returns (uint256) {
        return IBEP1155(ticketAddress).getPriceTicket(ticketId);
    }

    function buy1155Ticket(address ticketAddress, uint256 ticketId, uint256 amount) public payable {
        require(
            msg.value >= _ticket1155Data[ticketAddress][ticketId]._price * 10**18,
            "Error, Token costs more"
        );
        require (_ticket1155Data[ticketAddress][ticketId]._amount >= amount, "Error, Not enough ticket");
        require (_ticket1155Data[ticketAddress][ticketId]._amount > 0, "Error, Not enough ticket");
        _ticket1155Data[ticketAddress][ticketId]._amount -= 1;
        if(_ticket1155Data[ticketAddress][ticketId]._amount == 0)
            _ticket1155Data[ticketAddress][ticketId]._soldOut = 1;
        IBEP1155(ticketAddress).safeTransferFrom(address(this), _msgSender(), ticketId, amount, "0x");
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