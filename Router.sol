// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import "https://github.com/Uniswap/solidity-lib/blob/master/contracts/libraries/TransferHelper.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract Uniswap3 {
  IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
  address private constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
  
  mapping(address => mapping(uint => uint256)) public outputEthForAddress;
  mapping(address => uint) public txCount;

  function convertExactTokenToEth(uint256 tokenAmount, uint256 minimumEthReceived, address tokenAddress, uint256 _deadline) external payable {
      
    require(tokenAmount > 0, "Must pass non 0 token amount");

    uint256 deadline = _deadline;
    address tokenIn = tokenAddress;
    address tokenOut = WETH9;
    uint256 amountIn = tokenAmount;
    uint256 amountOutMinimum = minimumEthReceived;
    
    TransferHelper.safeTransferFrom(tokenAddress, msg.sender, address(this), tokenAmount);
    
    TransferHelper.safeApprove(tokenAddress, address(uniswapRouter), tokenAmount);
    
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
        tokenIn,
        tokenOut,
        10000,
        msg.sender,
        deadline,
        amountIn,
        amountOutMinimum,
        0
    );
    
    uint256 amountOut = uniswapRouter.exactInputSingle(params);
    
    // Store transaction count used for last eth amount received
    txCount[msg.sender] = txCount[msg.sender] + 1;
    uint currentTxCount = txCount[msg.sender];
    
    // Store last eth amount received
    outputEthForAddress[msg.sender][currentTxCount] = amountOut;
  }
  
  function convertEthToExactToken(uint256 tokenAmount, address tokenAddress, uint256 _deadline) external payable {
    require(tokenAmount > 0, "Must pass non 0 token amount");
    require(msg.value > 0, "Must pass non 0 ETH amount");
      
    uint256 deadline = _deadline;
    address tokenIn = WETH9;
    address tokenOut = tokenAddress;
    uint24 fee = 10000;
    address recipient = msg.sender;
    uint256 amountOut = tokenAmount;
    uint256 amountInMaximum = msg.value;
    uint160 sqrtPriceLimitX96 = 0;

    ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
        tokenIn,
        tokenOut,
        fee,
        recipient,
        deadline,
        amountOut,
        amountInMaximum,
        sqrtPriceLimitX96
    );

    uniswapRouter.exactOutputSingle{ value: msg.value }(params);
    uniswapRouter.refundETH();

    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "refund failed");
  }
  
  function getEthOutputValue() public view returns(uint256) {
      return outputEthForAddress[msg.sender][txCount[msg.sender]];
  }
  
  receive() payable external {}
}
