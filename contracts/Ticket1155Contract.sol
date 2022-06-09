// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Ticket1155Contract is ERC1155, AccessControl {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;

    string private _name;
    address private _owner;
    uint256 private _typeCount;

    event initTicketEvent (uint256 _id, string _type, uint256 _supply);
    event sellTicketEvent (uint256 _id, uint256 _supply);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct TicketInfo {
        string _type;
        uint256 _supply;
        uint256 _price;
        bool _isSet;
    }

    mapping(uint256 => TicketInfo) private _ticketInfo;
    mapping(address => EnumerableSet.UintSet) internal idOfUsers;

    constructor(string memory name, address owner) ERC1155("") public {
        _name = name;
        _owner = owner;
        _setupRole(MINTER_ROLE, owner);
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function getName() external view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    function getLengthTicketInfo() external view returns (uint256) {
        return _typeCount;
    }

    function getTicketInfo(uint256 _id) external view returns (TicketInfo memory) {
        return _ticketInfo[_id];
    }

    function getPriceTicket(uint256 _id) external view returns (uint256) {
        return _ticketInfo[_id]._price;
    }

    function initTicket( string[] memory _types, uint256[] memory _supplies, uint256[] memory _prices ) public {
        for (uint256 i = 0; i < _types.length; i++) {
            require(_supplies[i] != 0, "1155: supply should be positive");
            _ticketInfo[_typeCount]._type = _types[i];
            _ticketInfo[_typeCount]._supply = _supplies[i];
            _ticketInfo[_typeCount]._price = _prices[i];
            _ticketInfo[_typeCount]._isSet = true;
            _mint(_msgSender(), _typeCount, _supplies[i], "0x");
            idOfUsers[_msgSender()].add(_typeCount);
            _typeCount++;
            emit initTicketEvent(i, _types[i], _supplies[i]);
        }
    }

    function getLengthNftOfUser (address user) external view returns (uint256) {
        return idOfUsers[user].length();
    }

    function getIdOfUserAtIndex(address account, uint256 index) external view returns (uint256){
        return idOfUsers[account].at(index);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) public override {
        _safeTransferFrom(_from, _to, _id, _value, _data);
        if (balanceOf(_from, _id) == 0) {
            idOfUsers[_from].remove(_id);
        }
        idOfUsers[_to].add(_id);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155, AccessControl)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }



}