pragma solidity ^0.4.16;

interface IntroToken {
    function transfer(address receiver, uint amount);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


contract IntroCrowdsale is Pausable {
    using SafeMath for uint256;

    address public investWallet1 = 0x39C4814ad52266b697Ff23F2A34A52178dF9FeB0;
    address public investWallet2 = 0x3c542ed7b58a9578657a63619B03D262dDc90c70;
    address public investWallet3 = 0xf511c17680617c569A12Eb0979Ac404867F52d87;
    IntroToken public tokenReward;

    uint256 public etherUsdPrice = 544; // 1 ETH = 544 USD
    uint256 public minimalUSD = 12; // 12 usd minimal price
    uint256 public tokenPriceUsd = 28; // 0.28 usd = 1 token
    uint256 public commission1 = 35;
    uint256 public commission2 = 35;

    function IntroCrowdsale(address _tokenReward) {
        tokenReward = IntroToken(_tokenReward);
    }

    function () payable {
        buy(msg.sender);
    }

    function buy(address buyer) payable {
        require(buyer != address(0));
        require(msg.value != 0);
        require(msg.value >= minimalUSD.mul(10 ** 18).div(etherUsdPrice));

        uint amount = msg.value;
        uint tokens = amount.div(tokenPriceUsd).mul(100).mul(etherUsdPrice);
        tokenReward.transfer(buyer, tokens);

        investWallet1.transfer(amount.div(100).mul(commission1));
        investWallet2.transfer(amount.div(100).mul(commission2));
        investWallet3.transfer(this.balance);
    }

    function updatePrice(uint256 _etherUsdPrice) onlyOwner {
        etherUsdPrice = _etherUsdPrice;
    }

    function updateMinimal(uint256 _minimalUSD) onlyOwner {
        minimalUSD = _minimalUSD;
    }

    function transferTokens(uint256 _tokens) onlyOwner {
        tokenReward.transfer(owner, _tokens); 
    }

    function setNew1Commission(uint256 _commission1) onlyOwner {
        commission1 = _commission1; 
    }

    function setNew2Commission(uint256 _commission2) onlyOwner {
        commission2 = _commission2; 
    }

    function airdrop(address[] _array1, uint256[] _array2) onlyOwner {
       address[] memory arrayAddress = _array1;
       uint256[] memory arrayAmount = _array2;
       uint256 arrayLength = arrayAddress.length.sub(1);
       uint256 i = 0;
       
       while (i <= arrayLength) {
           tokenReward.transfer(arrayAddress[i], arrayAmount[i]);
           i = i.add(1);
       }  
   }

}
