// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Materials} from "../../src/Materials.sol";
import {Assembler} from "../../src/Assembler.sol";
import {DeployMaterials} from "../../script/DeployScript.s.sol";

contract AssemblerTest is Test {
    Materials materials;
    Assembler assembler;

    address public ALICE = makeAddr("Alice");
    uint256 public FORGE_COST = 0.05 ether;

    function setUp() public {
        DeployMaterials deployer = new DeployMaterials();
        (materials, assembler) = deployer.run();
        vm.startPrank(materials.owner());
        materials.transferOwnership(address(this));
        assembler.transferOwnership(address(this));
        vm.stopPrank();
    }
    //////////////////////
    /// Test Forge
    //////////////////////

    modifier setAssembler() {
        materials.setAssembler(address(assembler));
        _;
    }

    modifier setBlockTime() {
        vm.warp(166123123);
        _;
    }

    function testRevertForge_IfTokenIdInvalid() public setBlockTime {
        uint256 tokenId = 3;
        vm.expectRevert(Assembler.Assembler__InvalidTokenId.selector);
        assembler.forge{value: FORGE_COST}(tokenId);
    }

    function testRevertForge_IfAmountIsNotEnough() public setBlockTime {
        uint256 katana_Id = assembler.KATANA();
        vm.expectRevert(Assembler.Assembler__AmountNotEnough.selector);
        assembler.forge{value: 0.005 ether}(katana_Id);
    }

    function testRevertForge_IfResourcesAreLow() public setBlockTime {
        uint256 katana_Id = assembler.KATANA();
        vm.expectRevert(Assembler.Assembler__NotEnoughResources.selector);
        assembler.forge{value: FORGE_COST}(katana_Id);
    }

    event Forged(address indexed user, uint256 tokenId, uint256 value);

    modifier mintMaterialsAndApproveAsAlice() {
        vm.deal(ALICE, 10 ether);
        vm.startPrank(ALICE);
        uint256 mintAmount = 100;
        materials.mint{value: 0.005 ether * mintAmount}(0, 100);
        materials.mint{value: 0.005 ether * mintAmount}(1, 100);
        materials.mint{value: 0.005 ether * mintAmount}(2, 100);
        materials.mint{value: 0.005 ether * mintAmount}(3, 100);
        materials.setApprovalForAll(address(assembler), true);
        vm.stopPrank();
        _;
    }

    function testForge_BasicSword() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.BASIC_SWORD();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 0), 100 - 2);
        assertEq(materials.balanceOf(ALICE, 2), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 4), 1);
        vm.stopPrank();
    }

    function testForge_BasicShield() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.BASIC_SHIELD();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 0), 100 - 3);
        assertEq(materials.balanceOf(ALICE, 1), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 2), 100 - 2);
        assertEq(materials.balanceOf(ALICE, 5), 1);
        vm.stopPrank();
    }

    function testForge_StoneHammer() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.STONE_HAMMER();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 0), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 1), 100 - 2);
        assertEq(materials.balanceOf(ALICE, 6), 1);
        vm.stopPrank();
    }

    function testForge_MetalSword() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.METAL_SWORD();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 2), 100 - 3);
        assertEq(materials.balanceOf(ALICE, 7), 1);
        vm.stopPrank();
    }

    function testForge_MetalArmor() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.METAL_ARMOR();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 2), 100 - 5);
        assertEq(materials.balanceOf(ALICE, 8), 1);
        vm.stopPrank();
    }

    function testForge_Katana() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.KATANA();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 0), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 1), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 2), 100 - 5);
        assertEq(materials.balanceOf(ALICE, 3), 100 - 1);
        assertEq(materials.balanceOf(ALICE, 9), 1);
        vm.stopPrank();
    }

    function testForge_GoldArmor() public setBlockTime mintMaterialsAndApproveAsAlice {
        vm.startPrank(ALICE);

        uint256 tokenIdToForge = assembler.GOLD_ARMOR();
        vm.expectEmit(true, false, false, false, address(assembler));
        emit Forged(ALICE, tokenIdToForge, 1);
        assembler.forge{value: FORGE_COST}(tokenIdToForge);

        assertEq(materials.balanceOf(ALICE, 2), 100 - 2);
        assertEq(materials.balanceOf(ALICE, 3), 100 - 5);
        assertEq(materials.balanceOf(ALICE, 10), 1);
        vm.stopPrank();
    }

    function testWithdraw() public {
        testForge_BasicShield();

        uint256 startingBalance = address(assembler).balance;
        console.log("Assembler Owner:", assembler.owner());
        console.log("Owner:", address(this));
        assembler.withdraw(startingBalance);

        assertEq(address(assembler).balance, startingBalance - startingBalance);
    }

    //////////////////////////
    /// Test View Functions
    //////////////////////////

    function testGetAssembler() public {
        assertEq(materials.assembler(), address(assembler));
    }

    function testGetMaterials() public {
        assertEq(assembler.getMaterialsContract(), address(materials));
    }

    function testGetTokenUri() public {
        string memory katanaUri = assembler.getTokenUri(assembler.KATANA());
        assertEq(materials.uri(9), katanaUri);
    }

    receive() external payable {}
    fallback() external payable {}
}
