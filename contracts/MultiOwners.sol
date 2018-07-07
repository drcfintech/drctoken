pragma solidity ^0.4.23;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "zeppelin-solidity/contracts/ownership/DelayedClaimable.sol";
import "zeppelin-solidity/contracts/ownership/rbac/RBAC.sol";
import "./StringUtils.sol";


/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract MultiOwners is DelayedClaimable, RBAC {
  using SafeMath for uint256;
  using StringUtils for string;

  mapping (string => uint256) private authorizations;
  mapping (address => string) private ownerOfSides;
//   mapping (string => mapping (string => bool)) private voteResults;
  mapping (string => uint256) private sideExist;
  mapping (string => mapping (string => address[])) private sideVoters;
  address[] private owners;
  string[] private authTypes;
//   string[] private ownerSides;
  uint256 multiOwnerSides;
  uint256 ownerSidesLimit = 3;
//   uint256 authRate = 75;
  bool initAdd = true;

  event OwnerAdded(address addr, string side);
  event OwnerRemoved(address addr);
  event InitialFinished();

  string public constant ROLE_MULTIOWNER = "multiOwner";
  string public constant AUTH_ADDOWNER = "addOwner";
  string public constant AUTH_REMOVEOWNER = "removeOwner";
//   string public constant AUTH_SETAUTHRATE = "setAuthRate";

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyMultiOwners() {
    checkRole(msg.sender, ROLE_MULTIOWNER);
    _;
  }

  function authorize(string _authType) onlyMultiOwners public {
    string memory side = ownerOfSides[msg.sender];
    address[] storage voters = sideVoters[side][_authType];
    if (voters.length == 0) {
      authorizations[_authType] = authorizations[_authType].add(1);
    //   voteResults[side][_authType] = true;
    }

    uint j = 0;
    for (; j < voters.length; j = j.add(1)) {
      if (voters[j] == msg.sender) {
        break;
      }
    }

    if (j >= voters.length) {
      voters.push(msg.sender);
    }

    uint i = 0;
    for (; i < authTypes.length; i = i.add(1)) {
      if (authTypes[i].equal(_authType)) {
        break;
      }
    }

    if (i >= authTypes.length) {
      authTypes.push(_authType);
    }
  }

  function deAuthorize(string _authType) onlyMultiOwners public {
    string memory side = ownerOfSides[msg.sender];
    address[] storage voters = sideVoters[side][_authType];

    for (uint j = 0; j < voters.length; j = j.add(1)) {
      if (voters[j] == msg.sender) {
        delete voters[j];
        break;
      }
    }
    for (uint jj = j; jj < voters.length.sub(1); jj = jj.add(1)) {
      voters[jj] = voters[jj.add(1)];
    }

    delete voters[voters.length.sub(1)];
    voters.length = voters.length.sub(1);
    
    if (voters.length == 0) {
      authorizations[_authType] = authorizations[_authType].sub(1);
    //   voteResults[side][_authType] = true;
    }

    if (authorizations[_authType] == 0) {
      for (uint i = 0; i < authTypes.length; i = i.add(1)) {
        if (authTypes[i].equal(_authType)) {
          delete authTypes[i];
          break;
        }
      }
      for (uint ii = i; ii < authTypes.length.sub(1); ii = ii.add(1)) {
        authTypes[ii] = authTypes[ii.add(1)];
      }

      delete authTypes[authTypes.length.sub(1)];
      authTypes.length = authTypes.length.sub(1);
    }
  }

//   function ownerSidesCount() internal returns (uint256) {
//     uint256 multiOwnerSides = 0;
//     for (uint i = 0; i < owners.length; i = i.add(1)) {
//       string storage side = ownerOfSides[owners[i]];
//       if (!sideExist[side]) {
//         sideExist[side] = true;
//         multiOwnerSides = multiOwnerSides.add(1);
//       }
//     }

//     return multiOwnerSides;
//   }

  function hasAuth(string _authType) public view returns (bool) {
    require(multiOwnerSides > 1);
    
    // uint256 rate = authorizations[_authType].mul(100).div(multiOwnerNumber)
    return (authorizations[_authType] == multiOwnerSides);
  }

  function clearAuth(string _authType) internal {
    authorizations[_authType] = 0;
    for (uint i = 0; i < owners.length; i = i.add(1)) {
      string memory side = ownerOfSides[owners[i]];
      address[] storage voters = sideVoters[side][_authType];
      for (uint j = 0; j < voters.length; j = j.add(1)) {
        delete voters[j];
      }
      voters.length = 0;
    }
    
    for (uint k = 0; k < authTypes.length; k = k.add(1)) {
      if (authTypes[k].equal(_authType)) {
        delete authTypes[k];
        break;
      }
    }
    for (uint kk = k; kk < authTypes.length.sub(1); kk = kk.add(1)) {
      authTypes[kk] = authTypes[kk.add(1)];
    }

    delete authTypes[authTypes.length.sub(1)];
    authTypes.length = authTypes.length.sub(1);
  }

//   function setAuthRate(uint256 _value) onlyMultiOwners public {
//     require(hasAuth(AUTH_SETAUTHRATE));
//     require(_value > 0);

//     authRate = _value;
//     clearAuth(AUTH_SETAUTHRATE);
//   }

  function addAddress(address _addr, string _side) internal {
    uint i = 0;
    for (; i < owners.length; i = i.add(1)) {
      if (owners[i] == _addr) {
        break;
      }
    }

    if (i >= owners.length) {
      owners.push(_addr);

      addRole(_addr, ROLE_MULTIOWNER);    
      ownerOfSides[_addr] = _side;
    }

    if (sideExist[_side] == 0) {        
      multiOwnerSides = multiOwnerSides.add(1);
    }

    sideExist[_side] = sideExist[_side].add(1);
  }

  /**
   * @dev add an address to the whitelist
   * @param _addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function initAddressAsMultiOwner(address _addr, string _side)
    onlyOwner
    public
  {
    require(initAdd);
    require(multiOwnerSides < ownerSidesLimit);

    addAddress(_addr, _side);

    // initAdd = false;
    emit OwnerAdded(_addr, _side);
  }

  /**
   * @dev Function to stop initial stage.
   */
  function finishInitOwners() onlyOwner public {
    initAdd = false;
    emit InitialFinished();
  }

  /**
   * @dev add an address to the whitelist
   * @param _addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressAsMultiOwner(address _addr, string _side)
    onlyMultiOwners
    public
  {
    require(hasAuth(AUTH_ADDOWNER));
    require(multiOwnerSides < ownerSidesLimit);

    addAddress(_addr, _side);
        
    clearAuth(AUTH_ADDOWNER);
    emit OwnerAdded(_addr, _side);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function isMultiOwner(address _addr)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, ROLE_MULTIOWNER);
  }

  /**
   * @dev add addresses to the whitelist
   * @param _addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
//   function InitAddressesAsMultiOwner(address[] _addrs, bytes[] _sides)
//     onlyOwner
//     public
//   {
//     require(initAdd);
//     require(_addrs.length == _sides.length);

//     for (uint256 i = 0; i < _addrs.length; i = i.add(1)) {
//       require(ownerSidesCount() < ownerSidesLimit);

//       addRole(_addrs[i], ROLE_MULTIOWNER);
//       ownerOfSides[_addrs[i]] = string(_sides[i]);
//       uint j = 0;
//       for (; j < owners.length; j = j.add(1)) {
//         if (owners[j] == _addrs[i]) {
//           break;
//         }
//       }

//       if (i >= owners.length) {
//         owners.push(_addrs[i]);
//       }
    
//       clearAuth(AUTH_ADDOWNER);
//       emit OwnerAdded(_addrs[i], string(_sides[i]));
//     }

//     initAdd = false;
//   }

  /**
   * @dev add addresses to the whitelist
   * @param _addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
//   function AddAddressesAsMultiOwner(address[] _addrs, bytes[] _sides)
//     onlyMultiOwners
//     public
//   {
//     require(hasAuth(AUTH_ADDOWNER));
//     require(_addrs.length == _sides.length);

//     for (uint256 i = 0; i < _addrs.length; i = i.add(1)) {
//       require(ownerSidesCount() < ownerSidesLimit);

//       addRole(_addrs[i], ROLE_MULTIOWNER);
//       ownerOfSides[_addrs[i]] = string(_sides[i]);
//       uint j = 0;
//       for (; j < owners.length; j = j.add(1)) {
//         if (owners[j] == _addrs[i]) {
//           break;
//         }
//       }

//       if (j >= owners.length) {
//         owners.push(_addrs[i]);
//       }

//       emit OwnerAdded(_addrs[i], string(_sides[i]));
//     }

//     clearAuth(AUTH_ADDOWNER);
//   }

  /**
   * @dev remove an address from the whitelist
   * @param _addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromOwners(address _addr)
    onlyMultiOwners
    public
  {
    require(hasAuth(AUTH_REMOVEOWNER));

    removeRole(_addr, ROLE_MULTIOWNER);   

    uint j = 0;
    for (; j < owners.length; j = j.add(1)) {
      if (owners[j] == _addr) {
        delete owners[j];
        break;
      }
    }
    for (uint jj = j; jj < owners.length.sub(1); jj = jj.add(1)) {
      owners[jj] = owners[jj.add(1)];
    }

    delete owners[owners.length.sub(1)];
    owners.length = owners.length.sub(1);

    string memory side = ownerOfSides[_addr];
    if (sideExist[side] > 0) {
      sideExist[side] = sideExist[side].sub(1);
      if (sideExist[side] == 0) {
        multiOwnerSides = multiOwnerSides.sub(1);
        for (uint i = 0; i < authTypes.length; ) {
          address[] storage voters = sideVoters[side][authTypes[i]];
          for (uint k = 0; k < voters.length; k = k.add(1)) {
            delete voters[k];
          }
          voters.length = 0;

          authorizations[authTypes[i]] = authorizations[authTypes[i]].sub(1);
          if (authorizations[authTypes[i]] == 0) {
            delete authTypes[i];
            
            for (uint kk = i; kk < authTypes.length.sub(1); kk = kk.add(1)) {
              authTypes[kk] = authTypes[kk.add(1)];
            }

            delete authTypes[authTypes.length.sub(1)];
            authTypes.length = authTypes.length.sub(1);
          } else {
            i = i.add(1);
          }
        }
      }
    } 

    delete ownerOfSides[_addr];    

    clearAuth(AUTH_REMOVEOWNER);
    emit OwnerRemoved(_addr);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param _addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
//   function removeAddressesFromOwners(address[] _addrs)
//     onlyMultiOwners
//     public
//   {
//     require(hasAuth(AUTH_REMOVEOWNER));
//     for (uint i = 0; i < _addrs.length; i = i.add(1)) {
//       removeRole(_addrs[i], ROLE_MULTIOWNER);
//       ownerOfSides[_addrs[i]] = "";
//       uint j = 0;
//       for (; j < owners.length; j = j.add(1)) {
//         if (owners[j] == _addrs[i]) {
//           delete owners[j];
//         }
//       }

//       emit OwnerRemoved(_addrs[i]);
//     }

//     clearAuth(AUTH_REMOVEOWNER);
//   }

}
