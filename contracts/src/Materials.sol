// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;

import {ERC1155, ERC1155Burnable} from "@oz/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";
import {Strings} from "@oz/contracts/utils/Strings.sol";

contract Materials is ERC1155, ERC1155Burnable, Ownable {
    using Strings for uint256;

    ////////////////
    /// Errors
    ////////////////
    error Materials__Cooldown();
    error Materials__AmountNotEnough();
    error Materials__InvalidTokenId();
    error Materials__QuantityIsZero();
    error Materials__ArrayLengthMisMatch();

    ////////////////
    /// Variables
    ////////////////
    address public assembler;
    string public constant NAME = "Materials";
    string public constant SYMBOL = "MAT";

    // Available Materials to Mint
    uint256 public constant WOOD = 0;
    uint256 public constant STONE = 1;
    uint256 public constant IRON = 2;
    uint256 public constant GOLD = 3;

    /*
     Price for minting Materials
     Same for all Materials
    */
    uint256 constant MINT_PRICE = 0.005 ether;

    /*
     User has to wait 24 hours to claim again
    */
    uint256 constant CLAIM_COOLDOWN = 24 hours;

    ////////////////
    /// Mappings
    ////////////////

    /*
     To track user cooldown
    */
    mapping(address user => uint256 cooldown) public userCooldown;

    ////////////////
    /// Events
    ////////////////
    event ResourceClaim(address indexed user, uint256 indexed tokenId, uint256 amount);

    constructor() ERC1155("https://ipfs.io/ipfs/QmdDk94vYjni1ptr84pJND1eHixNDRiccr8TfrEcvur8y7/") {
        _mint(msg.sender, 0, 1e6, "");
        _mint(msg.sender, 1, 1e6, "");
        _mint(msg.sender, 2, 1e6, "");
        _mint(msg.sender, 3, 1e6, "");
    }

    ////////////////
    /// MODIFIERS
    ////////////////
    modifier isQuantityZero(uint256 _amount) {
        if (_amount == 0) revert Materials__QuantityIsZero();
        _;
    }

    modifier isTokenIdValid(uint256 _tokenId) {
        if (_tokenId > GOLD) revert Materials__InvalidTokenId();
        _;
    }

    ////////////////////////
    /// Public Functions
    ////////////////////////

    /**
     * @param _tokenId - token id to mint
     * @param _amount - amount of token to mint
     * Cost of minting 1 token is 0.005 ether
     */

    function mint(uint256 _tokenId, uint256 _amount) public payable isTokenIdValid(_tokenId) isQuantityZero(_amount) {
        if (msg.value != MINT_PRICE * _amount) revert Materials__AmountNotEnough();
        _mint(msg.sender, _tokenId, _amount, "");
    }

    /**
     * Claim Free Materials
     * User Needs to wait 24 hours in order to Claim again
     */
    function claimResources() external {
        if (userCooldown[msg.sender] + CLAIM_COOLDOWN > block.timestamp) revert Materials__Cooldown();

        uint256 randomNum = uint256(bytes32(keccak256(abi.encodePacked(block.prevrandao, block.timestamp)))) % 100;

        if (randomNum > 0 && randomNum < 12) {
            _mint(msg.sender, GOLD, randomNum, "");
            emit ResourceClaim(msg.sender, GOLD, randomNum);
        } else if (randomNum > 12 && randomNum < 22) {
            _mint(msg.sender, IRON, randomNum, "");
            emit ResourceClaim(msg.sender, IRON, randomNum);
        } else if (randomNum > 22 && randomNum < 32) {
            _mint(msg.sender, STONE, randomNum, "");
            emit ResourceClaim(msg.sender, STONE, randomNum);
        } else {
            _mint(msg.sender, WOOD, randomNum, "");
            emit ResourceClaim(msg.sender, WOOD, randomNum);
        }
        // Update User Cooldown
        userCooldown[msg.sender] = block.timestamp;
    }

    //////////////////////
    /// Assembler Mint
    //////////////////////

    /**
     * @param user - Address of user who will receive nft
     * @param _tokenId - Token id to mind
     * @param _amount - amount of token to mint
     * !Only callable by Assembler
     */

    function forgeMint(address user, uint256 _tokenId, uint256 _amount) external {
        if (msg.sender != assembler) revert("Not Assembler");
        _mint(user, _tokenId, _amount, "");
    }

    /////////////////////
    /// Admin Functions
    /////////////////////
    function airDrop(uint256 _tokenId, uint256[] calldata _amount, address[] calldata _recipients)
        external
        isTokenIdValid(_tokenId)
        onlyOwner
    {
        if (_amount.length != _recipients.length) revert Materials__ArrayLengthMisMatch();

        for (uint256 i; i < _recipients.length;) {
            _mint(_recipients[i], _tokenId, _amount[i], "");

            unchecked {
                ++i;
            }
        }
    }

    function setAssembler(address _newAddress) external onlyOwner {
        assembler = _newAddress;
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount >= address(this).balance, "Contract Balance Low");

        (bool success,) = msg.sender.call{value: _amount}("");

        if (!success) revert();
    }

    /////////////////////////
    /// View, Pure Functions
    /////////////////////////

    function uri(uint256 _tokenId) public pure override returns (string memory) {
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/QmdDk94vYjni1ptr84pJND1eHixNDRiccr8TfrEcvur8y7/", _tokenId.toString(), ".json"
            )
        );
    }
}
