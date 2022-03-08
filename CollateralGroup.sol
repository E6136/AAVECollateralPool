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
	}

	function withdraw() external {
		
	}

	function borrow(address asset, uint amount) external {
		
	}

	function repay(address asset, uint amount) external {
		
	}
}