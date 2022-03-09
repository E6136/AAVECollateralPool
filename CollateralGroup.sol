// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./ILendingPool.sol";

contract CollateralGroup {
	ILendingPool pool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
	IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
	IERC20 aDai = IERC20(0x028171bCA77440897B824Ca71D1c56caC55b68A3); 

	uint depositAmount = 10000e18;
	address[] members;

	constructor(address[] memory _members) {
       members = _members;
	  
	   for(uint i = 0; i < members.length; i++) {
		   dai.transferFrom(members[i], address(this), depositAmount);
	   }
       
       /*Now that all the members have paid their DAI deposit, 
       we can deposit it all into the AAVE lending pool. 
       This will allow us to start earning interest on the DAI 
       and also allow it to serve as collateral for future borrows.*/
       dai.approve(address(pool), type(uint).max);
      
	   pool.deposit(address(dai), dai.balanceOf(address(this)), address(this), 0);
	}

	/*When members are ready to remove their funds, and there are no outstanding loans, 
	anyone can call the withdraw function. 
	This function should kick off a withdrawal for all members. 
	For each member it should pay them back their initial deposit 
	plus their share of any interest earned.*/
	function withdraw() external {
		uint share = aDai.balanceOf(address(this)) / members.length;
		
		aDai.approve(address(pool), type(uint).max);
		
		for(uint i = 0; i < members.length; i++) {
			pool.withdraw(address(dai), share, members[i]);
		}
	}

	/*After the members have transferred their DAI to the smart contract, 
	let's allow any member to borrow against it. 
	Let's support any ERC20 token that has reserves in the AAVE system.
	In the CollateralGroup borrow function, call borrow on the AAVE pool 
	to borrow the amount of asset specified by the arguments.*/
	function borrow(address asset, uint amount) external {
		pool.borrow(asset, amount, 1, 0, address(this));/*The third parameter is the interestRateMode that 
														should either be 1 for stable or 2 for variable rates.
														https://docs.aave.com/faq/borrowing#what-is-the-difference-between-stable-and-variable-rate*/
		
		IERC20(asset).transfer(msg.sender, amount);/*After being borrowed, the asset is transferred to the function caller*/
	}

	/*When a member is ready to repay their loan, they need to call the repay function. 
	Before calling this function they will need to approve the collateral group 
	to spend the particular asset, otherwise the transfer will fail.*/
	function repay(address asset, uint amount) external {
		IERC20(asset).transferFrom(msg.sender, address(this), amount);
		
		IERC20(asset).approve(address(pool), amount);
		
		pool.repay(asset, amount, 1, address(this));/*The third parameter is the rateMode that must 
													be the same as that in the borrow function*/ 
	}
}
