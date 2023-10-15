// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {WETH} from "../src/WETH.sol";

contract WETHTest is Test, WETH {
    WETH public weth;
	address public user1;
	
    function setUp() public {
        weth = new WETH();
		user1 = makeAddr("user1");
		deal(user1, 1 ether);
		vm.label(msg.sender, "MSG.SENDER");
		vm.label(address(this), "THIS");
		vm.label(address(weth), "WETH");
    }

    // - 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function test_when_deposit_msg_value_should_mint_erc20_token_to_user() public {
		vm.startPrank(user1);
        uint256 amount = 20;
        weth.deposit{value: amount}();
        assertEq(weth.balanceOf(address(user1)), amount);
		vm.stopPrank();
    }

    // - 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function test_when_deposit_msg_value_should_transfer_ether_to_contract() public {
		vm.startPrank(user1);
		uint256 amount = 20;
		weth.deposit{value: amount}();
		assertEq(address(weth).balance, amount);
		vm.stopPrank();
    }

    // - 測項 3: deposit 應該要 emit Deposit event
    function test_when_call_deposit_should_emit_Deposit_event() public {
		vm.startPrank(user1);
		uint256 amount = 20;
		vm.expectEmit(true, false, false, true, address(weth));
		emit Deposit(address(user1), amount);

		weth.deposit{value: amount}();
		vm.stopPrank();
	}

    // - 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
	function test_when_withdraw_given_amount_should_burn_given_amount() public {
		vm.startPrank(user1);
		uint256 amount = 20;
		deal(address(weth), address(user1), amount);
		weth.withdraw(amount);
		assertEq(weth.balanceOf(address(user1)), 0);
		vm.stopPrank();
	}
    
    // - 測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function test_when_withdraw_given_amount_should_transfer_given_amount_to_user() public {
		vm.startPrank(user1);
		uint256 amount = 20;
		deal(address(weth), address(user1), amount);
		weth.withdraw(amount);
		vm.stopPrank();
	}
    
    // - 測項 6: withdraw 應該要 emit Withdraw event
    function test_when_call_withdraw_should_emit_Withdraw_event() public {
		vm.startPrank(user1);
		uint256 amount = 20;
		deal(address(weth), address(user1), amount);
		vm.expectEmit(true, false, false, true, address(weth));
		emit Withdrawal(address(user1), amount);

		weth.withdraw(amount);
		vm.stopPrank();
	}
    
    // - 測項 7: transfer 應該要將 erc20 token 轉給別人
    function test_when_transfer_should_sucessful_transfer() public {
		vm.startPrank(user1);
		deal(address(weth), address(user1),100);	
		uint256 amount = 20;
		address user2 = makeAddr("user2");
		weth.transfer(user2, amount);
		assertEq(weth.balanceOf(address(user2)), amount);
		vm.stopPrank();
	}

    // - 測項 8: approve 應該要給他人 allowance
    function test_when_approve_given_amount_should_allowance_given_amount_to_user() public {
		vm.startPrank(user1);
		deal(address(weth), address(user1),100);	
		address spender = makeAddr("spender");
		uint256 amount = 20;
		weth.approve(spender, amount);
		assertEq(weth.allowance(address(user1), spender), amount);
		vm.stopPrank();
	}

    // - 測項 9: transferFrom 應該要可以使用他人的 allowance
    function test_when_allowance_given_amount_should_able_transferFrom_given_amount() public {
		deal(address(weth), address(user1), 20);	
		address spender = makeAddr("spender");
		uint256 amount = 20;
		vm.prank(user1);
		weth.approve(spender, amount);
		vm.prank(spender);
		(bool success) = weth.transferFrom(address(user1), spender, amount);
		assertTrue(success);
	}

    // - 測項 10: transferFrom 後應該要減除用完的 allowance
    function test_when_transferForm_given_amount_should_allowance_decrease_given_amount() public {
		deal(address(weth), address(user1), 20);	
		address spender = makeAddr("spender");
		uint256 amount = 20;
		vm.prank(user1);
		weth.approve(spender, amount);
		uint beforeTransferFromAllowance = weth.allowance(address(user1), spender);
		vm.prank(spender);
		weth.transferFrom(address(user1), spender, amount);
		uint afterTransferFromAllowance = weth.allowance(address(user1), spender);
		assertEq(afterTransferFromAllowance, beforeTransferFromAllowance - amount);
	}
    
}