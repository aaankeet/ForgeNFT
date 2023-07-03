// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Materials} from "../../src/Materials.sol";
import {DeployMaterials} from "../../script/DeployScript.s.sol";

contract MaterialsTest is Test {
    Materials materials;

    uint256 MINT_QUANTITY = 5;
    uint256 MINT_PRICE = 0.005 ether;

    address public ALICE = makeAddr("ALICE");

    function setUp() public {
        DeployMaterials deploy = new DeployMaterials();
        (materials,) = deploy.run();
    }

    //////////////////////
    /// Test Constructor
    //////////////////////

    function testConstructor() public {
        assertEq(materials.balanceOf(materials.owner(), 0), 1e6);
        assertEq(materials.balanceOf(materials.owner(), 1), 1e6);
        assertEq(materials.balanceOf(materials.owner(), 2), 1e6);
        assertEq(materials.balanceOf(materials.owner(), 3), 1e6);
    }

    ////////////////
    /// Mint
    ////////////////
    function testRevertMintIfTokenIdInvalid() public {
        uint256 invalidTokenId = 5;
        vm.expectRevert(Materials.Materials__InvalidTokenId.selector);
        materials.mint{value: MINT_PRICE * MINT_QUANTITY}(invalidTokenId, MINT_QUANTITY);
    }

    function testRevertMintIfAmountIsNotEnough() public {
        uint256 validTokenId = materials.GOLD();
        vm.expectRevert(Materials.Materials__AmountNotEnough.selector);
        materials.mint{value: MINT_PRICE}(validTokenId, MINT_QUANTITY);
    }

    function testRevertMintIfQuantityIsZero() public {
        uint256 validTokenId = materials.GOLD();
        vm.expectRevert(Materials.Materials__QuantityIsZero.selector);
        materials.mint{value: MINT_PRICE}(validTokenId, 0);
    }

    function testMintToken() public {
        vm.deal(ALICE, 10 ether);
        vm.startPrank(ALICE);

        uint256 validTokenId = materials.GOLD();

        materials.mint{value: MINT_PRICE * MINT_QUANTITY}(validTokenId, MINT_QUANTITY);
        assertEq(materials.balanceOf(ALICE, validTokenId), MINT_QUANTITY);
        vm.stopPrank();
    }
    //////////////////////
    /// Test Forge Mint
    //////////////////////

    function testRevertForgeMint() public {
        vm.expectRevert();
        materials.forgeMint(ALICE, 1, 15);
    }

    //////////////////////
    /// Test Claim
    //////////////////////

    event ResourceClaim(address indexed user, uint256 indexed tokenId, uint256 amount);

    modifier setBlockTime() {
        // Set block.timestamp
        vm.warp(1641070800);
        console.log(block.timestamp);
        _;
    }

    function testClaimResources() public setBlockTime {
        vm.startPrank(ALICE);

        uint256 randomNum = uint256(bytes32(keccak256(abi.encodePacked(block.prevrandao, block.timestamp)))) % 100;
        uint256 tokenId;

        if (randomNum > 0 && randomNum < 12) {
            tokenId = materials.GOLD();
        } else if (randomNum > 12 && randomNum < 22) {
            tokenId = materials.IRON();
        } else if (randomNum > 22 && randomNum < 32) {
            tokenId = materials.STONE();
        } else {
            tokenId = materials.WOOD();
        }

        vm.expectEmit(true, true, false, false, address(materials));
        emit ResourceClaim(ALICE, tokenId, randomNum);
        materials.claimResources();

        assertEq(materials.balanceOf(ALICE, tokenId), randomNum);
        vm.stopPrank();
    }

    function testRevertClaimResourcesIfCooldown() public {
        testClaimResources();

        // Increase block.timestamp by 1 hr
        skip(3600);

        vm.startPrank(ALICE);

        vm.expectRevert(Materials.Materials__Cooldown.selector);
        materials.claimResources();
        console.log("User cooldown:", materials.userCooldown(ALICE));
        console.log("Current TimeStamp: ", block.timestamp);

        vm.stopPrank();
    }

    function testClaimResourcesAfter24Hours() public {
        testClaimResources();

        // Increase block.timestamp by 1 hr
        skip(24 hours);
        console.log("Current TimeStamp:", block.timestamp);

        vm.startPrank(ALICE);

        // User should be abe to Claim Again After 24 hours of cooldown
        uint256 randomNum = uint256(bytes32(keccak256(abi.encodePacked(block.prevrandao, block.timestamp)))) % 100;
        uint256 tokenId;

        if (randomNum > 0 && randomNum < 12) {
            tokenId = materials.GOLD();
        } else if (randomNum > 12 && randomNum < 22) {
            tokenId = materials.IRON();
        } else if (randomNum > 22 && randomNum < 32) {
            tokenId = materials.STONE();
        } else {
            tokenId = materials.WOOD();
        }

        vm.expectEmit(true, true, false, false, address(materials));
        emit ResourceClaim(ALICE, tokenId, randomNum);
        materials.claimResources();

        vm.stopPrank();
    }

    ////////////////////
    /// Test Air Drop
    ////////////////////

    uint256[] public amount;
    address[] public recipients;

    function testRevertAirDropArrayMismatch() public {
        amount.push(100);

        console.log("This Address:", address(this));
        console.log("Owner:", materials.owner());

        vm.startPrank(materials.owner());

        recipients.push(address(1));
        recipients.push(address(2));

        vm.expectRevert(Materials.Materials__ArrayLengthMisMatch.selector);
        materials.airDrop(1, amount, recipients);
        vm.stopPrank();
    }

    function testAirDrop_TokenInvalid() public {
        amount.push(100);
        recipients.push(address(1));
        recipients.push(address(2));

        vm.startPrank(materials.owner());

        vm.expectRevert(Materials.Materials__InvalidTokenId.selector);
        materials.airDrop(4, amount, recipients);
        vm.stopPrank();
    }

    function testAirDrop() public {
        amount.push(200);
        amount.push(300);

        recipients.push(address(1));
        recipients.push(address(2));

        vm.startPrank(materials.owner());

        materials.airDrop(1, amount, recipients);

        assertEq(materials.balanceOf(address(1), 1), 200);
        assertEq(materials.balanceOf(address(2), 1), 300);
    }

    /////////////////////////
    /// Test Withdraw
    /////////////////////////

    function testWithdraw() public {
        testMintToken();

        uint256 startingContractBalance = address(materials).balance;
        uint256 ownerStartingBalance = materials.owner().balance;

        console.log("Contract Starting Balance:", startingContractBalance);
        console.log("Owner Starting Balance:", ownerStartingBalance);

        vm.startPrank(materials.owner());

        materials.withdraw(startingContractBalance);

        uint256 latestContractBalance = address(materials).balance;
        uint256 latestOwnerBalance = materials.owner().balance;

        assertEq(latestContractBalance, startingContractBalance - startingContractBalance);
        assertEq(latestOwnerBalance, ownerStartingBalance + startingContractBalance);
    }

    function testRevertWithdraw() public {
        testMintToken();
        vm.expectRevert();

        uint256 startingContractBalance = address(materials).balance;
        materials.withdraw(startingContractBalance);
    }

    ///////////////////
    /// Test Uri
    ///////////////////

    function testUri() public {
        uint256 tokenId = 1;
        string memory uriOfTokenIdOne = "https://ipfs.io/ipfs/QmdDk94vYjni1ptr84pJND1eHixNDRiccr8TfrEcvur8y7/1.json";

        string memory uri = materials.uri(tokenId);

        assertEq(uriOfTokenIdOne, uri);
    }

    function testTokenIds() public {
        assertEq(materials.WOOD(), 0);
        assertEq(materials.STONE(), 1);
        assertEq(materials.IRON(), 2);
        assertEq(materials.GOLD(), 3);

        assertEq(materials.NAME(), "Materials");
        assertEq(materials.SYMBOL(), "MAT");
    }
}
