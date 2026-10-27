// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Test} from "forge-std/Test.sol";
import {CedarToken} from "src/CedarToken.sol";
import {DeployCedarToken} from "script/DeployCedarToken.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract CedarTokenTest is Test {
    CedarToken public cedarToken;
    DeployCedarToken public deployer;

    address jacob = makeAddr("Jacob");
    address ray = makeAddr("Ray");

    address public spender = makeAddr("spender");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployCedarToken();
        cedarToken = deployer.run();

        vm.prank(address(msg.sender));
        cedarToken.transfer(jacob, STARTING_BALANCE);
    }

    function testJacobBalance() public view {
        assertEq(STARTING_BALANCE, cedarToken.balanceOf(jacob));
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT
    //////////////////////////////////////////////////////////////*/

    function testInitialSupply() public view {
        assertEq(cedarToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testTokenName() public view {
        assertEq(cedarToken.name(), "CedarToken");
    }

    function testTokenSymbol() public view {
        assertEq(cedarToken.symbol(), "CT");
    }

    function testTokenDecimals() public view {
        assertEq(cedarToken.decimals(), 18);
    }

    function testUsersCantMint() public {
        vm.expectRevert();

        MintableToken(address(cedarToken)).mint(address(this), 1);
    }

    /*//////////////////////////////////////////////////////////////
                              TRANSFERS
    //////////////////////////////////////////////////////////////*/

    function testTransfer() public {
        uint256 amount = 10 ether;

        vm.prank(jacob);
        bool success = cedarToken.transfer(ray, amount);

        assertTrue(success);
        assertEq(cedarToken.balanceOf(jacob), STARTING_BALANCE - amount);
        assertEq(cedarToken.balanceOf(ray), amount);
    }

    function testTransferEntireBalance() public {
        vm.prank(jacob);
        cedarToken.transfer(ray, STARTING_BALANCE);

        assertEq(cedarToken.balanceOf(jacob), 0);
        assertEq(cedarToken.balanceOf(ray), STARTING_BALANCE);
    }

    function testTransferZeroTokens() public {
        vm.prank(jacob);
        bool success = cedarToken.transfer(ray, 0);

        assertTrue(success);
        assertEq(cedarToken.balanceOf(jacob), STARTING_BALANCE);
        assertEq(cedarToken.balanceOf(ray), 0);
    }

    function testTransferFailsWhenBalanceIsInsufficient() public {
        vm.prank(jacob);
        vm.expectRevert();

        cedarToken.transfer(ray, STARTING_BALANCE + 1);
    }

    /*//////////////////////////////////////////////////////////////
                              ALLOWANCES
    //////////////////////////////////////////////////////////////*/

    function testApprove() public {
        uint256 allowanceAmount = 50 ether;

        vm.prank(jacob);
        bool success = cedarToken.approve(spender, allowanceAmount);

        assertTrue(success);

        assertEq(cedarToken.allowance(jacob, spender), allowanceAmount);
    }

    function testApprovalCanBeChanged() public {
        vm.startPrank(jacob);

        cedarToken.approve(spender, 50 ether);

        assertEq(cedarToken.allowance(jacob, spender), 50 ether);

        cedarToken.approve(spender, 25 ether);

        assertEq(cedarToken.allowance(jacob, spender), 25 ether);

        vm.stopPrank();
    }

    function testApprovalCanBeRevoked() public {
        vm.startPrank(jacob);

        cedarToken.approve(spender, 50 ether);
        cedarToken.approve(spender, 0);

        vm.stopPrank();

        assertEq(cedarToken.allowance(jacob, spender), 0);
    }

    /*//////////////////////////////////////////////////////////////
                            TRANSFER FROM
    //////////////////////////////////////////////////////////////*/

    function testTransferFrom() public {
        uint256 allowanceAmount = 50 ether;
        uint256 transferAmount = 20 ether;

        // jacob gives spender permission.
        vm.prank(jacob);
        cedarToken.approve(spender, allowanceAmount);

        // Spender transfers jacob's tokens to ray.
        vm.prank(spender);
        bool success = cedarToken.transferFrom(jacob, ray, transferAmount);

        assertTrue(success);

        assertEq(
            cedarToken.balanceOf(jacob),
            STARTING_BALANCE - transferAmount
        );

        assertEq(cedarToken.balanceOf(ray), transferAmount);

        assertEq(
            cedarToken.allowance(jacob, spender),
            allowanceAmount - transferAmount
        );
    }

    function testTransferFromFailsWithoutAllowance() public {
        vm.prank(spender);
        vm.expectRevert();

        cedarToken.transferFrom(jacob, ray, 10 ether);
    }

    function testTransferFromFailsWhenExceedingAllowance() public {
        vm.prank(jacob);
        cedarToken.approve(spender, 10 ether);

        vm.prank(spender);
        vm.expectRevert();

        cedarToken.transferFrom(jacob, ray, 11 ether);
    }

    function testTransferFromFailsWhenBalanceIsInsufficient() public {
        // Allow spender to spend more than jacob owns.
        vm.prank(jacob);
        cedarToken.approve(spender, STARTING_BALANCE + 1);

        vm.prank(spender);
        vm.expectRevert();

        cedarToken.transferFrom(jacob, ray, STARTING_BALANCE + 1);
    }

    /*//////////////////////////////////////////////////////////////
                             FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    function testFuzzTransfer(uint256 amount) public {
        amount = bound(amount, 0, STARTING_BALANCE);

        vm.prank(jacob);
        cedarToken.transfer(ray, amount);

        assertEq(cedarToken.balanceOf(jacob), STARTING_BALANCE - amount);

        assertEq(cedarToken.balanceOf(ray), amount);
    }

    function testFuzzApprove(uint256 amount) public {
        vm.prank(jacob);
        cedarToken.approve(spender, amount);

        assertEq(cedarToken.allowance(jacob, spender), amount);
    }

    function testFuzzTransferFrom(
        uint256 allowanceAmount,
        uint256 transferAmount
    ) public {
        allowanceAmount = bound(allowanceAmount, 0, STARTING_BALANCE);

        transferAmount = bound(transferAmount, 0, allowanceAmount);

        vm.prank(jacob);
        cedarToken.approve(spender, allowanceAmount);

        vm.prank(spender);
        cedarToken.transferFrom(jacob, ray, transferAmount);

        assertEq(
            cedarToken.balanceOf(jacob),
            STARTING_BALANCE - transferAmount
        );

        assertEq(cedarToken.balanceOf(ray), transferAmount);

        assertEq(
            cedarToken.allowance(jacob, spender),
            allowanceAmount - transferAmount
        );
    }
}
