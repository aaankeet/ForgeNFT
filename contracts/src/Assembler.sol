// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;

import {Materials} from "./Materials.sol";
import {Ownable} from "@oz/contracts/access/Ownable.sol";

contract Assembler is Ownable {
    Materials materials;

    /////////////
    /// Errors
    /////////////

    error Assembler__InvalidTokenId();
    error Assembler__AmountNotEnough();
    error Assembler__NotEnoughResources();
    error Assembler__ForgeCooldown();

    ////////////////
    /// Variables
    ////////////////

    uint256 public constant BASIC_SWORD = 4;
    uint256 public constant BASIC_SHIELD = 5;
    uint256 public constant STONE_HAMMER = 6;

    uint256 public constant METAL_SWORD = 7;
    uint256 public constant METAL_ARMOR = 8;

    uint256 public constant KATANA = 9;
    uint256 public constant GOLD_ARMOR = 10;

    // To keep things simple we keep forging cost constant
    uint256 public constant FORGE_COST = 0.05 ether;

    // User needs to wait 1 minute to forge again
    uint256 public constant FORGE_COOLDOWN = 1 minutes;

    //////////////////
    /// Mappings
    //////////////////

    mapping(address user => uint256 time) public userForgeCooldown;

    //////////////////
    /// Events
    //////////////////

    event Forged(address indexed user, uint256 tokenId, uint256 value);

    ////////////////////
    /// Constructor
    ////////////////////

    ////////////////////
    /// Modifiers
    ////////////////////

    modifier isTokenIdValid(uint256 _tokenId) {
        if (_tokenId < BASIC_SWORD || _tokenId > GOLD_ARMOR) revert Assembler__InvalidTokenId();
        _;
    }

    /////////////////////////
    /// Public Functions
    /////////////////////////

    /**
     * @param _tokenId - Token to Forge, Available tokens are 4-10
     * Forging Cost 0.05 ether
     * User Needs to wait 1 minute after Forging in order to forge again.
     */

    function forge(uint256 _tokenId) external payable isTokenIdValid(_tokenId) {
        if (msg.value != FORGE_COST) revert Assembler__AmountNotEnough();
        if (userForgeCooldown[msg.sender] + FORGE_COOLDOWN > block.timestamp) revert Assembler__ForgeCooldown();

        // Get ids of raw materials
        uint256 woodId = materials.WOOD();
        uint256 stoneId = materials.STONE();
        uint256 ironId = materials.IRON();
        uint256 goldId = materials.GOLD();

        // Get user's raw material balances
        uint256 woodBalance = materials.balanceOf(msg.sender, woodId);
        uint256 stoneBalance = materials.balanceOf(msg.sender, stoneId);
        uint256 ironBalance = materials.balanceOf(msg.sender, ironId);
        uint256 goldBalance = materials.balanceOf(msg.sender, goldId);

        // Since we know there are only 4 raw materials, We can use
        uint256[] memory idsToBurn = new uint256[](4);
        uint256[] memory valuesToBurn = new uint256[](4);

        if (_tokenId == BASIC_SWORD) {
            // Mint Basic Sword for 2 Wood & 1 Iron
            if (woodBalance < 2 && ironBalance < 1) revert Assembler__NotEnoughResources();

            idsToBurn[0] = woodId;
            idsToBurn[1] = ironId;
            valuesToBurn[0] = 2;
            valuesToBurn[1] = 1;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, BASIC_SWORD, 1);

            emit Forged(msg.sender, BASIC_SWORD, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else if (_tokenId == BASIC_SHIELD) {
            // Mint Basic Shield for 3 wood, 1 stone & 2 iron
            if (woodBalance < 3 && stoneBalance < 1 && ironBalance < 2) revert Assembler__NotEnoughResources();

            idsToBurn[0] = woodId;
            idsToBurn[1] = stoneId;
            idsToBurn[2] = ironId;

            valuesToBurn[0] = 3;
            valuesToBurn[1] = 1;
            valuesToBurn[2] = 2;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, BASIC_SHIELD, 1);

            emit Forged(msg.sender, BASIC_SHIELD, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else if (_tokenId == STONE_HAMMER) {
            // Mint Stone Hammer for 1 wood, 2 stone
            if (woodBalance < 1 && stoneBalance < 2) revert Assembler__NotEnoughResources();

            idsToBurn[0] = woodId;
            idsToBurn[1] = stoneId;

            valuesToBurn[0] = 1;
            valuesToBurn[1] = 2;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, STONE_HAMMER, 1);

            emit Forged(msg.sender, STONE_HAMMER, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else if (_tokenId == METAL_SWORD) {
            // Mint Metal Sword for 3 iron
            if (ironBalance < 3) revert Assembler__NotEnoughResources();

            idsToBurn[0] = ironId;
            valuesToBurn[0] = 3;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, METAL_SWORD, 1);
            emit Forged(msg.sender, METAL_SWORD, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else if (_tokenId == METAL_ARMOR) {
            // Mint Metal Armor for 5 iron
            if (ironBalance < 5) revert Assembler__NotEnoughResources();

            idsToBurn[0] = ironId;
            valuesToBurn[0] = 5;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, METAL_ARMOR, 1);

            emit Forged(msg.sender, METAL_ARMOR, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else if (_tokenId == KATANA) {
            // Mint Katana for 1 wood, 1 stone, 5 iron & 1 Gold
            if (woodBalance < 1 && stoneBalance < 1 && ironBalance < 5 && goldBalance < 1) {
                revert Assembler__NotEnoughResources();
            }

            idsToBurn[0] = woodId;
            idsToBurn[1] = stoneId;
            idsToBurn[2] = ironId;
            idsToBurn[3] = goldId;

            valuesToBurn[0] = 1;
            valuesToBurn[1] = 1;
            valuesToBurn[2] = 5;
            valuesToBurn[3] = 1;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, KATANA, 1);

            emit Forged(msg.sender, KATANA, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        } else {
            // Mint Gold Armor for 2 iron & 5 Gold
            if (ironBalance < 2 && goldBalance < 5) revert Assembler__NotEnoughResources();

            idsToBurn[0] = ironId;
            idsToBurn[1] = goldId;
            valuesToBurn[0] = 2;
            valuesToBurn[1] = 5;

            materials.burnBatch(msg.sender, idsToBurn, valuesToBurn);
            materials.forgeMint(msg.sender, GOLD_ARMOR, 1);

            emit Forged(msg.sender, GOLD_ARMOR, 1);

            userForgeCooldown[msg.sender] = block.timestamp;
        }
    }

    ///////////////////////
    /// Admin Functions
    ///////////////////////

    function setMaterials(address _addr) external onlyOwner {
        materials = Materials(_addr);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount >= address(this).balance, "Contract Balance Low");

        (bool success,) = msg.sender.call{value: _amount}("");

        if (!success) revert();
    }
    /////////////////////////////////
    /// Public View, Pure Functions
    /////////////////////////////////

    function getTokenUri(uint256 _tokenId) public view returns (string memory) {
        return materials.uri(_tokenId);
    }

    function getMaterialsContract() public view returns (address) {
        return address(materials);
    }
}
