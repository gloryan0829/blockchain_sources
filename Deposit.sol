pragma solidity ^0.5.0;
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Deposit3M is Context {
    using SafeMath for uint256;
    
    address payable public banker;
    
    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositDates;
    
    uint256 public totalPrincipalBalance;
    uint256 public totalInterestBalance;
    
    uint256 constant TwoMonths = 60 days;
    uint256 constant ThreeMonths = 90 days;
    uint256 constant SixMonths = 180 days;
    
    // Event Logs
    event Deposited(address indexed depositor, uint256 value, uint256 fromBalance, uint256 toBalance, 
                    uint256 interestPeriod, uint256 interest, uint256 fee);
    event Withdrawn(address indexed depositor, uint256 value, uint256 interest, uint256 fee);
    event GivenBack(address indexed msgSender, address indexed depositor, uint256 value);
    event Canceled(address indexed depositor, uint256 value, uint256 penalty);
    
    // Constructor
    constructor() public {
        banker = _msgSender();
    }
    
    // Modifiers
    modifier onlyLess3Months(address depositor) {
        require(now.sub(depositDates[_msgSender()]) < ThreeMonths, "해당 계정에서 금액을 맡긴지 3개월이 지났습니다.");
        _;
    }
    
    modifier onlyOver3MonthsAndLess6Months(address depositor) {
        require(now.sub(depositDates[_msgSender()]) >= ThreeMonths, "해당 계정에서 금액을 맡긴지 3개월이 지나야 합니다.");
        require(now.sub(depositDates[_msgSender()]) <= SixMonths, "해당 계정에서 금액을 맡긴지 6개월이 지나지 않아야 합니다.");
        _;
    }
    modifier onlyOver6Months(address depositor) {
        require(now.sub(depositDates[_msgSender()]) > SixMonths, "해당 계정에서 금액을 맡긴지 6개월이 지나지 않았습니다.");
        _;
    }
    
    // Fallback Function
    /**
     * @dev 예금 맡김
     * - 만약 기존에 맡긴 예금이 존재한다면, 다음을 원금으로 편입하고 날짜 계산을 reset 한다.
     * - (2개월 이내일 때) 기존의 원금 + 추가된 원금 + (기간에 비례한 이자) * 0.5
     * - (3개월 이내일 때) 기존의 원금 + 추가된 원금 + (기간에 비례한 이자) * 0.7
     * - (3개월~6개월 이내) 기존의 원금 + 추가된 원금 + 만기 해약 이자
     * - (6개월 이후일 때) 기존의 원금 + 추가된 원금 (이자 없음)
     * - 이 때 이자의 10% 는 수수료로 banker 에게 제공한다.
     */ 
    function() external payable {
        address depositor = _msgSender();
        uint256 value = msg.value;
        
        uint256 fromBalance = balances[depositor];
        
        // 새로 예금을 맡긴 경우
        if (fromBalance == 0) {
            balances[depositor] = value;
            depositDates[depositor] = now;
            totalPrincipalBalance = totalPrincipalBalance.add(value);
            
            emit Deposited(depositor, value, 0, value, 0, 0, 0);
            return;
        }
        // 기존에 맡긴 예금이 있는 경우
        uint256 interestPeriod = now.sub(depositDates[depositor]);
        uint256 interest = 0;
        
        if (interestPeriod < SixMonths) {
            interest = totalInterestBalance.mul(fromBalance).div(totalPrincipalBalance); // 금액에 비례한 이자 (만기 기준)
            
            if (interestPeriod < ThreeMonths) {
                interest = interest.mul(interestPeriod).div(ThreeMonths); // 3개월 기준 기간에 비례한 이자
                
                if (interestPeriod < TwoMonths) {
                    interest = interest.div(2); // * 0.5
                } else {
                    interest = interest.mul(7).div(10); // * 0.7
                }
            }
        }
        uint256 fee = interest.div(10);
        interest = interest.sub(fee);
        balances[depositor] = balances[depositor].add(interest).add(value);
        depositDates[depositor] = now;
        
        totalPrincipalBalance = totalPrincipalBalance.add(interest).add(value);
        totalInterestBalance = totalInterestBalance.sub(interest).sub(fee);
        
        banker.transfer(fee);
        
        emit Deposited(depositor, value, fromBalance, balances[depositor], interestPeriod, interest, fee);
    }
    
    // Public Functions
    /**
     * @dev 만기 해약
     * - 이자 pool 에 쌓인 금액을 (나의 예금 금액) / (전체 예금 금액) 비율로 이자로 가져간다.
     * - 이 때 10% 는 수수료로 banker 에게 제공한다.
     */ 
    function withdraw() public onlyOver3MonthsAndLess6Months(_msgSender()) {
        address payable depositor = _msgSender();
        uint256 value = balances[depositor];
        
        uint256 interest = totalInterestBalance.mul(value).div(totalPrincipalBalance);
        uint256 fee = interest.div(10);
        interest = interest.sub(fee);
        
        totalPrincipalBalance = totalPrincipalBalance.sub(value);
        totalInterestBalance = totalInterestBalance.sub(interest).sub(fee);
        
        depositor.transfer(value.add(interest));
        banker.transfer(fee);
        
        emit Withdrawn(depositor, value, interest, fee);
    }
    
    /**
     * @dev 6개월 이상 지난 계정에 대해 돈을 돌려주는 함수 (누구나 실행 가능)
     * - 키의 분실 등으로 계정 접근이 불가능해 묶이는 돈들이 생길 수 있는데,
     * - 이러한 돈들은 이자의 일부 또한 계속 묶여두게 만든다.
     * - 따라서 3~6개월 이내에 찾아가는 것을 원칙으로 하고, 찾아가지 않은 계정은 원금만을 돌려준다.
     */
    function giveBack(address payable depositor) public onlyOver6Months(depositor) {
        uint256 value = balances[depositor];
        totalPrincipalBalance = totalPrincipalBalance.sub(value);
        delete balances[depositor];
        delete depositDates[depositor];
        
        depositor.transfer(value);
        
        emit GivenBack(_msgSender(), depositor, value);
    }
    
    /**
     * @dev 3개월 이내 해약하기
     * - 2개월 이내는 50% 만 돌려받고
     * - 2~3개월 이내는 70% 를 돌려받는다.
     * - 위약금은 이자 pool 로 편입된다.
     */ 
    function cancel() onlyLess3Months(_msgSender()) public {
        address payable depositor = _msgSender();
        uint value;
        uint penalty;
        
        if (now.sub(depositDates[depositor]) < TwoMonths) {
            value = balances[depositor].div(2);
        } else {
            value = balances[depositor].mul(7).div(10);
        }
        
        penalty = balances[depositor].sub(value);
        totalPrincipalBalance = totalPrincipalBalance.sub(value);
        totalInterestBalance = totalInterestBalance.add(penalty);
        
        delete balances[depositor];
        delete depositDates[depositor];
        
        depositor.transfer(value);
        
        emit Canceled(depositor, value, penalty);
    }
}