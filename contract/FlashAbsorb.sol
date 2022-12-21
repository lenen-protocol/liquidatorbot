
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

/**
 * @title LenenProtocol's Comet Math Contract
 * @dev Pure math functions
 * @author LenenProtocol
 */
contract CometMath {
    /** Custom errors **/

    // error InvalidUInt64();
    // error InvalidUInt104();
    // error InvalidUInt128();
    // error InvalidInt104();
    // error InvalidInt256();
    // error NegativeNumber();

    function safe64(uint256 n) internal pure returns (uint64) {
        // if (n > type(uint64).max) revert InvalidUInt64();
        if (n > type(uint64).max) revert("InvalidUInt64");
        return uint64(n);
    }

    function safe104(uint256 n) internal pure returns (uint104) {
        // if (n > type(uint104).max) revert InvalidUInt104();
        if (n > type(uint104).max) revert("InvalidUInt104");
        return uint104(n);
    }

    function safe128(uint256 n) internal pure returns (uint128) {
        // if (n > type(uint128).max) revert InvalidUInt128();
        if (n > type(uint128).max) revert("InvalidUInt128");
        return uint128(n);
    }

    function signed104(uint104 n) internal pure returns (int104) {
        // if (n > uint104(type(int104).max)) revert InvalidInt104();
        if (n > uint104(type(int104).max)) revert("InvalidInt104");
        return int104(n);
    }

    function signed256(uint256 n) internal pure returns (int256) {
        // if (n > uint256(type(int256).max)) revert InvalidInt256();
        if (n > uint256(type(int256).max)) revert("InvalidInt256");
        return int256(n);
    }

    function unsigned104(int104 n) internal pure returns (uint104) {
        // if (n < 0) revert NegativeNumber();
        if (n < 0) revert("NegativeNumber");
        return uint104(n);
    }

    function unsigned256(int256 n) internal pure returns (uint256) {
        // if (n < 0) revert NegativeNumber();
        if (n < 0) revert("NegativeNumber");
        return uint256(n);
    }

    function toUInt8(bool x) internal pure returns (uint8) {
        return x ? 1 : 0;
    }

    function toBool(uint8 x) internal pure returns (bool) {
        return x != 0;
    }
}

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

/**
 * @title LenenProtocol's Comet Storage Interface
 * @dev Versions can enforce append-only storage slots via inheritance.
 * @author LenenProtocol
 */
contract CometStorage {
    // 512 bits total = 2 slots
    struct TotalsBasic {
        // 1st slot
        uint64 baseSupplyIndex;
        uint64 baseBorrowIndex;
        uint64 trackingSupplyIndex;
        uint64 trackingBorrowIndex;
        // 2nd slot
        uint104 totalSupplyBase;
        uint104 totalBorrowBase;
        uint40 lastAccrualTime;
        uint8 pauseFlags;
    }

    struct TotalsCollateral {
        uint128 totalSupplyAsset;
        uint128 _reserved;
    }

    struct UserBasic {
        int104 principal;
        uint64 baseTrackingIndex;
        uint64 baseTrackingAccrued;
        uint16 assetsIn;
        uint8 _reserved;
    }

    struct UserCollateral {
        uint128 balance;
        uint128 _reserved;
    }

    struct LiquidatorPoints {
        uint32 numAbsorbs;
        uint64 numAbsorbed;
        uint128 approxSpend;
        uint32 _reserved;
    }

    /// @dev Aggregate variables tracked for the entire market
    uint64 internal baseSupplyIndex;
    uint64 internal baseBorrowIndex;
    uint64 internal trackingSupplyIndex;
    uint64 internal trackingBorrowIndex;
    uint104 internal totalSupplyBase;
    uint104 internal totalBorrowBase;
    uint40 internal lastAccrualTime;
    uint8 internal pauseFlags;

    /// @notice Aggregate variables tracked for each collateral asset
    mapping(address => TotalsCollateral) public totalsCollateral;

    /// @notice Mapping of users to accounts which may be permitted to manage the user account
    mapping(address => mapping(address => bool)) public isAllowed;

    /// @notice The next expected nonce for an address, for validating authorizations via signature
    mapping(address => uint256) public userNonce;

    /// @notice Mapping of users to base principal and other basic data
    mapping(address => UserBasic) public userBasic;

    /// @notice Mapping of users to collateral data per collateral asset
    mapping(address => mapping(address => UserCollateral))
        public userCollateral;

    /// @notice Mapping of magic liquidator points
    mapping(address => LiquidatorPoints) public liquidatorPoints;
}
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

/**
 * @title LenenProtocol's Comet Configuration Interface
 * @author LenenProtocol
 */
contract CometConfiguration {
    struct ExtConfiguration {
        bytes32 name32;
        bytes32 symbol32;
    }

    struct Configuration {
        address governor;
        address pauseGuardian;
        address baseToken;
        address baseTokenPriceFeed;
        address extensionDelegate;
        uint64 supplyKink;
        uint64 supplyPerYearInterestRateSlopeLow;
        uint64 supplyPerYearInterestRateSlopeHigh;
        uint64 supplyPerYearInterestRateBase;
        uint64 borrowKink;
        uint64 borrowPerYearInterestRateSlopeLow;
        uint64 borrowPerYearInterestRateSlopeHigh;
        uint64 borrowPerYearInterestRateBase;
        uint64 storeFrontPriceFactor;
        uint64 trackingIndexScale;
        uint64 baseTrackingSupplySpeed;
        uint64 baseTrackingBorrowSpeed;
        uint104 baseMinForRewards;
        uint104 baseBorrowMin;
        uint104 targetReserves;
        AssetConfig[] assetConfigs;
    }

    struct AssetConfig {
        address asset;
        address priceFeed;
        uint8 decimals;
        uint64 borrowCollateralFactor;
        uint64 liquidateCollateralFactor;
        uint64 liquidationFactor;
        uint128 supplyCap;
    }
}

            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

////import "./CometConfiguration.sol";
////import "./CometStorage.sol";
////import "./CometMath.sol";
////import "./vendor/@victorlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

abstract contract CometCore is CometConfiguration, CometStorage, CometMath {
    struct AssetInfo {
        uint8 offset;
        address asset;
        address priceFeed;
        uint64 scale;
        uint64 borrowCollateralFactor;
        uint64 liquidateCollateralFactor;
        uint64 liquidationFactor;
        uint128 supplyCap;
    }

    /** Internal constants **/

    /// @dev The max number of assets this contract is hardcoded to support
    ///  Do not change this variable without updating all the fields throughout the contract,
    //    including the size of UserBasic.assetsIn and corresponding integer conversions.
    uint8 internal constant MAX_ASSETS = 15;

    /// @dev The max number of decimals base token can have
    ///  Note this cannot just be increased arbitrarily.
    uint8 internal constant MAX_BASE_DECIMALS = 18;

    /// @dev The max value for a collateral factor (1)
    uint64 internal constant MAX_COLLATERAL_FACTOR = FACTOR_SCALE;

    /// @dev Offsets for specific actions in the pause flag bit array
    uint8 internal constant PAUSE_SUPPLY_OFFSET = 0;
    uint8 internal constant PAUSE_TRANSFER_OFFSET = 1;
    uint8 internal constant PAUSE_WITHDRAW_OFFSET = 2;
    uint8 internal constant PAUSE_ABSORB_OFFSET = 3;
    uint8 internal constant PAUSE_BUY_OFFSET = 4;

    /// @dev The decimals required for a price feed
    uint8 internal constant PRICE_FEED_DECIMALS = 8;

    /// @dev 365 days * 24 hours * 60 minutes * 60 seconds
    uint64 internal constant SECONDS_PER_YEAR = 31_536_000;

    /// @dev The scale for base tracking accrual
    uint64 internal constant BASE_ACCRUAL_SCALE = 1e6;

    /// @dev The scale for base index (depends on time/rate scales, not base token)
    uint64 internal constant BASE_INDEX_SCALE = 1e15;

    /// @dev The scale for prices (in USD)
    uint64 internal constant PRICE_SCALE = uint64(10 ** PRICE_FEED_DECIMALS);

    /// @dev The scale for factors
    uint64 internal constant FACTOR_SCALE = 1e18;

    /**
     * @notice Determine if the manager has permission to act on behalf of the owner
     * @param owner The owner account
     * @param manager The manager account
     * @return Whether or not the manager has permission
     */
    function hasPermission(address owner, address manager) public view returns (bool) {
        return owner == manager || isAllowed[owner][manager];
    }

    /**
     * @dev The positive present supply balance if positive or the negative borrow balance if negative
     */
    function presentValue(int104 principalValue_) internal view returns (int256) {
        if (principalValue_ >= 0) {
            return signed256(presentValueSupply(baseSupplyIndex, uint104(principalValue_)));
        } else {
            return -signed256(presentValueBorrow(baseBorrowIndex, uint104(-principalValue_)));
        }
    }

    /**
     * @dev The principal amount projected forward by the supply index
     */
    function presentValueSupply(uint64 baseSupplyIndex_, uint104 principalValue_) internal pure returns (uint256) {
        return uint256(principalValue_) * baseSupplyIndex_ / BASE_INDEX_SCALE;
    }

    /**
     * @dev The principal amount projected forward by the borrow index
     */
    function presentValueBorrow(uint64 baseBorrowIndex_, uint104 principalValue_) internal pure returns (uint256) {
        return uint256(principalValue_) * baseBorrowIndex_ / BASE_INDEX_SCALE;
    }

    /**
     * @dev The positive principal if positive or the negative principal if negative
     */
    function principalValue(int256 presentValue_) internal view returns (int104) {
        if (presentValue_ >= 0) {
            return signed104(principalValueSupply(baseSupplyIndex, uint256(presentValue_)));
        } else {
            return -signed104(principalValueBorrow(baseBorrowIndex, uint256(-presentValue_)));
        }
    }

    /**
     * @dev The present value projected backward by the supply index (rounded down)
     *  Note: This will overflow (revert) at 2^104/1e18=~20 trillion principal for assets with 18 decimals.
     */
    function principalValueSupply(uint64 baseSupplyIndex_, uint256 presentValue_) internal pure returns (uint104) {
        return safe104((presentValue_ * BASE_INDEX_SCALE) / baseSupplyIndex_);
    }

    /**
     * @dev The present value projected backward by the borrow index (rounded up)
     *  Note: This will overflow (revert) at 2^104/1e18=~20 trillion principal for assets with 18 decimals.
     */
    function principalValueBorrow(uint64 baseBorrowIndex_, uint256 presentValue_) internal pure returns (uint104) {
        return safe104((presentValue_ * BASE_INDEX_SCALE + baseBorrowIndex_ - 1) / baseBorrowIndex_);
    }
}

            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

////import "./CometCore.sol";

/**
 * @title LenenProtocol's Comet Ext Interface
 * @notice An efficient monolithic money market protocol
 * @author LenenProtocol
 */
abstract contract CometExtInterface is CometCore {
    // error BadAmount();
    // error BadNonce();
    // error BadSignatory();
    // error InvalidValueS();
    // error InvalidValueV();
    // error SignatureExpired();

    function allow(address manager, bool isAllowed) external virtual;

    function allowBySig(
        address owner,
        address manager,
        bool isAllowed,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual;

    function collateralBalanceOf(address account, address asset)
        external
        view
        virtual
        returns (uint128);

    function baseTrackingAccrued(address account)
        external
        view
        virtual
        returns (uint64);

    function baseAccrualScale() external view virtual returns (uint64);

    function baseIndexScale() external view virtual returns (uint64);

    function factorScale() external view virtual returns (uint64);

    function priceScale() external view virtual returns (uint64);

    function maxAssets() external view virtual returns (uint8);

    function totalsBasic() external view virtual returns (TotalsBasic memory);

    function version() external view virtual returns (string memory);

    /**
     * ===== ERC20 interfaces =====
     * Does not include the following functions/events, which are defined in `CometMainInterface` instead:
     * - function decimals() virtual external view returns (uint8)
     * - function totalSupply() virtual external view returns (uint256)
     * - function transfer(address dst, uint amount) virtual external returns (bool)
     * - function transferFrom(address src, address dst, uint amount) virtual external returns (bool)
     * - function balanceOf(address owner) virtual external view returns (uint256)
     * - event Transfer(address indexed from, address indexed to, uint256 amount)
     */
    function name() external view virtual returns (string memory);

    function symbol() external view virtual returns (string memory);

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 amount)
        external
        virtual
        returns (bool);

    /**
     * @notice Get the current allowance from `owner` for `spender`
     * @param owner The address of the account which owns the tokens to be spent
     * @param spender The address of the account which may transfer tokens
     * @return The number of tokens allowed to be spent (-1 means infinite)
     */
    function allowance(address owner, address spender)
        external
        view
        virtual
        returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}
      
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

////import "./CometCore.sol";

/**
 * @title LenenProtocol's Comet Main Interface (without Ext)
 * @notice An efficient monolithic money market protocol
 * @author LenenProtocol
 */
abstract contract CometMainInterface is CometCore {
    // error Absurd();
    // error AlreadyInitialized();
    // error BadAsset();
    // error BadDecimals();
    // error BadDiscount();
    // error BadMinimum();
    // error BadPrice();
    // error BorrowTooSmall();
    // error BorrowCFTooLarge();
    // error InsufficientReserves();
    // error LiquidateCFTooLarge();
    // error NoSelfTransfer();
    // error NotCollateralized();
    // error NotForSale();
    // error NotLiquidatable();
    // error Paused();
    // error SupplyCapExceeded();
    // error TimestampTooLarge();
    // error TooManyAssets();
    // error TooMuchSlippage();
    // error TransferInFailed();
    // error TransferOutFailed();
    // error Unauthorized();

    event Supply(address indexed from, address indexed dst, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed src, address indexed to, uint256 amount);

    event SupplyCollateral(
        address indexed from,
        address indexed dst,
        address indexed asset,
        uint256 amount
    );
    event TransferCollateral(
        address indexed from,
        address indexed to,
        address indexed asset,
        uint256 amount
    );
    event WithdrawCollateral(
        address indexed src,
        address indexed to,
        address indexed asset,
        uint256 amount
    );

    /// @notice Event emitted when a borrow position is absorbed by the protocol
    event AbsorbDebt(
        address indexed absorber,
        address indexed borrower,
        uint256 basePaidOut,
        uint256 usdValue
    );

    /// @notice Event emitted when a user's collateral is absorbed by the protocol
    event AbsorbCollateral(
        address indexed absorber,
        address indexed borrower,
        address indexed asset,
        uint256 collateralAbsorbed,
        uint256 usdValue
    );

    /// @notice Event emitted when a collateral asset is purchased from the protocol
    event BuyCollateral(
        address indexed buyer,
        address indexed asset,
        uint256 baseAmount,
        uint256 collateralAmount
    );

    /// @notice Event emitted when an action is paused/unpaused
    event PauseAction(
        bool supplyPaused,
        bool transferPaused,
        bool withdrawPaused,
        bool absorbPaused,
        bool buyPaused
    );

    /// @notice Event emitted when reserves are withdrawn by the governor
    event WithdrawReserves(address indexed to, uint256 amount);

    function supply(address asset, uint256 amount) external virtual;

    function supplyTo(
        address dst,
        address asset,
        uint256 amount
    ) external virtual;

    function supplyFrom(
        address from,
        address dst,
        address asset,
        uint256 amount
    ) external virtual;

    function transfer(address dst, uint256 amount)
        external
        virtual
        returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external virtual returns (bool);

    function transferAsset(
        address dst,
        address asset,
        uint256 amount
    ) external virtual;

    function transferAssetFrom(
        address src,
        address dst,
        address asset,
        uint256 amount
    ) external virtual;

    function withdraw(address asset, uint256 amount) external virtual;

    function withdrawTo(
        address to,
        address asset,
        uint256 amount
    ) external virtual;

    function withdrawFrom(
        address src,
        address to,
        address asset,
        uint256 amount
    ) external virtual;

    function approveThis(
        address manager,
        address asset,
        uint256 amount
    ) external virtual;

    function withdrawReserves(address to, uint256 amount) external virtual;

    function absorb(address absorber, address[] calldata accounts)
        external
        virtual;

    function buyCollateral(
        address asset,
        uint256 minAmount,
        uint256 baseAmount,
        address recipient
    ) external virtual;

    function quoteCollateral(address asset, uint256 baseAmount)
        public
        view
        virtual
        returns (uint256);

    function getAssetInfo(uint8 i)
        public
        view
        virtual
        returns (AssetInfo memory);

    function getAssetInfoByAddress(address asset)
        public
        view
        virtual
        returns (AssetInfo memory);

    function getCollateralReserves(address asset)
        public
        view
        virtual
        returns (uint256);

    function getReserves() public view virtual returns (int256);

    function getPrice(address priceFeed) public view virtual returns (uint256);

    function isBorrowCollateralized(address account)
        public
        view
        virtual
        returns (bool);

    function isLiquidatable(address account) public view virtual returns (bool);

    function totalSupply() external view virtual returns (uint256);

    function totalBorrow() external view virtual returns (uint256);

    function balanceOf(address owner) public view virtual returns (uint256);

    function borrowBalanceOf(address account)
        public
        view
        virtual
        returns (uint256);

    function pause(
        bool supplyPaused,
        bool transferPaused,
        bool withdrawPaused,
        bool absorbPaused,
        bool buyPaused
    ) external virtual;

    function isSupplyPaused() public view virtual returns (bool);

    function isTransferPaused() public view virtual returns (bool);

    function isWithdrawPaused() public view virtual returns (bool);

    function isAbsorbPaused() public view virtual returns (bool);

    function isBuyPaused() public view virtual returns (bool);

    function accrueAccount(address account) external virtual;

    function getSupplyRate(uint256 utilization)
        public
        view
        virtual
        returns (uint64);

    function getBorrowRate(uint256 utilization)
        public
        view
        virtual
        returns (uint64);

    function getUtilization() public view virtual returns (uint256);

    function governor() external view virtual returns (address);

    function pauseGuardian() external view virtual returns (address);

    function baseToken() external view virtual returns (address);

    function baseTokenPriceFeed() external view virtual returns (address);

    function extensionDelegate() external view virtual returns (address);

    /// @dev uint64
    function supplyKink() external view virtual returns (uint256);

    /// @dev uint64
    function supplyPerSecondInterestRateSlopeLow()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function supplyPerSecondInterestRateSlopeHigh()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function supplyPerSecondInterestRateBase()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function borrowKink() external view virtual returns (uint256);

    /// @dev uint64
    function borrowPerSecondInterestRateSlopeLow()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function borrowPerSecondInterestRateSlopeHigh()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function borrowPerSecondInterestRateBase()
        external
        view
        virtual
        returns (uint256);

    /// @dev uint64
    function storeFrontPriceFactor() external view virtual returns (uint256);

    /// @dev uint64
    function baseScale() external view virtual returns (uint256);

    /// @dev uint64
    function trackingIndexScale() external view virtual returns (uint256);

    /// @dev uint64
    function baseTrackingSupplySpeed() external view virtual returns (uint256);

    /// @dev uint64
    function baseTrackingBorrowSpeed() external view virtual returns (uint256);

    /// @dev uint104
    function baseMinForRewards() external view virtual returns (uint256);

    /// @dev uint104
    function baseBorrowMin() external view virtual returns (uint256);

    /// @dev uint104
    function targetReserves() external view virtual returns (uint256);

    function numAssets() external view virtual returns (uint8);

    function decimals() external view virtual returns (uint8);

    function initializeStorage() external virtual;
}
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */
interface ERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    /**
      * @notice Get the total number of tokens in circulation
      * @return The supply of tokens
      */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transfer(address dst, uint256 amount) external returns (bool);

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    /**
      * @notice Approve `spender` to transfer up to `amount` from `src`
      * @dev This will overwrite the approval amount for `spender`
      *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
      * @param spender The address of the account which may transfer tokens
      * @param amount The number of tokens that are approved (-1 means infinite)
      * @return Whether or not the approval succeeded
      */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
      * @notice Get the current allowance from `owner` for `spender`
      * @param owner The address of the account which owns the tokens to be spent
      * @param spender The address of the account which may transfer tokens
      * @return The number of tokens allowed to be spent (-1 means infinite)
      */
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: BUSL-1.1
pragma solidity ^0.8.15;

////import "./CometMainInterface.sol";
////import "./CometExtInterface.sol";

/**
 * @title LenenProtocol's Comet Interface
 * @notice An efficient monolithic money market protocol
 * @author LenenProtocol
 */
abstract contract CometInterface is CometMainInterface, CometExtInterface {

}
      
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8;

////import "../../CometInterface.sol";
////import "../../ERC20.sol";

// uniswap will call this function when we execute the flash swap
interface IVanswapCallee {
    function VanswapCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

interface IWVS is ERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

interface IVanswapRouter {
    function factory() external pure returns (address);

    function WVS() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IVanswapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IVanswapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(ERC20.transferFrom.selector, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "STF"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(ERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ST"
        );
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(ERC20.approve.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SA"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "STE");
    }
}

// flash swap contract
// Only in vpioneer
contract FlashAbsorb is IVanswapCallee {
    /** Events **/
    event Absorb(address indexed initiator, address[] accounts);
    event Pay(
        address indexed token,
        address indexed payer,
        address indexed recipient,
        uint256 value
    );

    uint256 public constant QUOTE_PRICE_SCALE = 1e18;
    address public basetoken;

    /// @notice Address to send liquidation proceeds to
    address public admin;

    /// @notice Vanswap router used for token exchange
    IVanswapRouter public immutable swapRouter;

    /// @notice LenenProtocol Comet protocol
    CometInterface public immutable comet;

    /// @notice Minimum available amount for liquidation in USDC (base token)
    uint256 public liquidationThreshold;

    struct FlashCallbackData {
        uint256 amount;
        address recipient;
        address[] assets;
        uint256[] baseAmounts;
    }

    constructor(
        address _router,
        address _comet,
        uint256 _liquidationThreshold
    ) {
        admin = msg.sender;
        swapRouter = IVanswapRouter(_router);
        comet = CometInterface(_comet);
        basetoken = comet.baseToken();
        liquidationThreshold = _liquidationThreshold;
    }

    function setLiquidationThreshold(uint256 _liquidationThreshold) external {
        require(msg.sender == admin, "only admin");
        liquidationThreshold = _liquidationThreshold;
    }

    function setAdmin(address _newAdmin) external {
        require(msg.sender == admin, "only admin");
        require(_newAdmin != address(0), "renounce refused");
        admin = _newAdmin;
    }

    function adminWithdraw(address _token, address _to) external {
        require(msg.sender == admin, "only admin");
        if (_token == address(0x0)) {
            (bool success, ) = _to.call{value: address(this).balance}(
                new bytes(0)
            );
            return;
        }
        ERC20 token = ERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    /**
     * @dev Swaps the given asset to USDT (base token) using VanswapPair
     */
    function swapCollateral(address asset) internal returns (uint256) {
        uint256 swapAmount = ERC20(asset).balanceOf(address(this));
        // Safety check, make sure residue balance in protocol is ignored
        if (swapAmount == 0) return 0;

        TransferHelper.safeApprove(asset, address(swapRouter), swapAmount);

        // only one pair, no need to make choice
        address[] memory path = new address[](2);
        path[0] = asset;
        path[1] = basetoken;

        uint256[] memory receiveAmounts = swapRouter.swapExactTokensForTokens(
            swapAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        return receiveAmounts[receiveAmounts.length - 1];
    }

    /**
     * @dev Calculates the total amount of base asset needed to buy all the discounted collateral from the protocol
     */
    function calculateTotalBaseAmount()
        public
        view
        returns (
            uint256,
            uint256[] memory,
            address[] memory
        )
    {
        return calculateTotalBaseAmountWithSkip(false);
    }

    function calculateTotalBaseAmountWithSkip(bool skipBorrwoFrom)
        public
        view
        returns (
            uint256,
            uint256[] memory,
            address[] memory
        )
    {
        uint256 totalBaseAmount = 0;
        uint8 numAssets = comet.numAssets();
        uint256[] memory assetBaseAmounts = new uint256[](numAssets);
        address[] memory cometAssets = new address[](numAssets);
        for (uint8 i = 0; i < numAssets; i++) {
            address asset = comet.getAssetInfo(i).asset;
            cometAssets[i] = asset;
            uint256 collateralBalance = comet.getCollateralReserves(asset);

            if (collateralBalance == 0) continue;
            /// @notice can not swap collateral wvs to pair where usdt borrow from
            if (skipBorrwoFrom && asset == swapRouter.WVS()) continue;

            // Find the price in asset needed to base QUOTE_PRICE_SCALE of USDC (base token) of collateral
            uint256 quotePrice = comet.quoteCollateral(
                asset,
                QUOTE_PRICE_SCALE * comet.baseScale()
            );
            uint256 assetBaseAmount = (comet.baseScale() *
                QUOTE_PRICE_SCALE *
                collateralBalance) / quotePrice;

            // Liquidate only positions with adequate size, no need to collect residue from protocol
            if (assetBaseAmount < liquidationThreshold) continue;

            assetBaseAmounts[i] = assetBaseAmount;
            totalBaseAmount += assetBaseAmount;
        }

        return (totalBaseAmount, assetBaseAmounts, cometAssets);
    }

    // in return of flashloan call, vanswap will return with this function
    // providing us the token borrow and the amount
    // we also have to repay the borrowed amt plus some fees
    function VanswapCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external override {
        FlashCallbackData memory decoded = abi.decode(
            _data,
            (FlashCallbackData)
        );

        address[] memory assets = decoded.assets;
        TransferHelper.safeApprove(
            comet.baseToken(),
            address(comet),
            decoded.amount
        );

        // check msg.sender is the pair contract
        // take address of token0 n token1
        address token0 = IVanswapPair(msg.sender).token0();
        address token1 = IVanswapPair(msg.sender).token1();
        // call VanswapFactory to getpair
        address pair = IVanswapFactory(swapRouter.factory()).getPair(
            token0,
            token1
        );
        require(msg.sender == pair, "!pair");
        // check sender holds the address who initiated the flash loans
        require(_sender == address(this), "!sender");

        uint256 totalAmountOut = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            address asset = assets[i];
            uint256 baseAmount = decoded.baseAmounts[i];
            if (baseAmount == 0) continue; // no need absorb
            if (swapRouter.WVS() == asset) continue; // can not by from pair borrow asset, so wvs will not buy

            comet.buyCollateral(asset, 0, baseAmount, address(this));
            uint256 amountOut = swapCollateral(asset);
            totalAmountOut += amountOut;
        }

        // 0.3% fees
        // (usdt_return *.997) - usdt_borrow >=0
        // usdt_return >= usdt_borrow / .997
        // fee = usdt_borrow * (0.003/0.997) +1
        uint256 fee = ((decoded.amount * 3) / 997) + 1;
        payback(decoded.amount, fee, comet.baseToken(), totalAmountOut);
    }

    /**
     * @dev Returns loan to Uniswap pool and sends USDC (base token) profit to caller
     * @param amount The loan amount that need to be repaid
     * @param fee The fee for taking the loan
     * @param token The base token which was borrowed for successful liquidation
     * @param amountOut The total amount of base token received after liquidation
     */
    function payback(
        uint256 amount,
        uint256 fee,
        address token,
        uint256 amountOut
    ) internal {
        uint256 amountOwed = amount + fee;
        TransferHelper.safeApprove(token, address(this), amountOwed); // msg.sender???

        // Repay the loan
        if (amountOwed > 0) {
            pay(token, address(this), msg.sender, amountOwed);
            emit Pay(token, address(this), msg.sender, amountOwed);
        }

        // If profitable, pay profits to the caller
        if (amountOut > amountOwed) {
            uint256 profit = amountOut - amountOwed;
            TransferHelper.safeApprove(token, address(this), profit);
            pay(token, address(this), admin, profit);
            emit Pay(token, address(this), admin, profit);
        }
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address receipt,
        uint256 value
    ) internal {
        if (token == swapRouter.WVS() && address(this).balance >= value) {
            // pay with WETH9
            IWVS(swapRouter.WVS()).deposit{value: value}(); // wrap only what is needed to pay
            ERC20(swapRouter.WVS()).transfer(receipt, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            TransferHelper.safeTransfer(token, receipt, value);
        } else {
            // pull payment
            TransferHelper.safeTransferFrom(token, payer, receipt, value);
        }
    }

    function buyAndSellCollateral() public {
        // caculate amount will be used
        (
            uint256 totalBaseAmount,
            uint256[] memory assetBaseAmounts,
            address[] memory cometAssets
        ) = calculateTotalBaseAmountWithSkip(true);

        // check the pair contract for token borrow and weth exists
        // borrow from (wvs + basetoken), donot sell wvs on this pair
        address pair = IVanswapFactory(swapRouter.factory()).getPair(
            basetoken,
            swapRouter.WVS()
        );
        require(pair != address(0), "!pair");

        // right now we dont know tokenborrow belongs to which token
        address token0 = IVanswapPair(pair).token0();
        address token1 = IVanswapPair(pair).token1();

        // as a result, either amount0out will be equal to 0 or amount1out will be
        uint256 amount0Out = basetoken == token0 ? totalBaseAmount : 0;
        uint256 amount1Out = basetoken == token1 ? totalBaseAmount : 0;

        // need to pass some data to trigger uniswapv2call
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount: totalBaseAmount,
                recipient: msg.sender,
                assets: cometAssets,
                baseAmounts: assetBaseAmounts
            })
        );
        // last parameter tells whether its a normal swap or a flash swap
        // adding data triggers a flashloan
        IVanswapPair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    // we'll call this function to call to call FLASHLOAN on vanswap
    function initFlash(address[] memory _targets) external {
        // Absorb Comet underwater accounts
        comet.absorb(address(this), _targets);
        emit Absorb(msg.sender, _targets);
        buyAndSellCollateral();
    }
}

