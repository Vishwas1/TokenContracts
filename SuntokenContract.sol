pragma solidity ^0.4.0;

contract ERC20TokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    address owner;
 
    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _amount) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);

    function approve(address _spender, uint256 _amount) returns (bool success);

    function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract ERC20 is ERC20TokenInterface {
    
    function ERC20(address _owner){
        owner = _owner;
    }
    
    modifier noEther() {
        if (msg.value > 0)  
        _;
        
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[owner] >= _amount && _amount > 0) {
            balances[owner] -= _amount;
            balances[_to] += _amount;
            Transfer(owner, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][owner] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][owner] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[owner][_spender] = _amount;
        Approval(owner, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract SunCoin is ERC20{
    
    string public  name = "VAB Sun Coin";
    string public  symbol = "SUN";
    uint256 public totalSupply;
    uint public constant price = 0.001 ether;
    uint8 public  decimal = 0;
    
    event Log(string log);
    
    function SunCoin(uint _initialValue) ERC20(msg.sender){
        totalSupply = _initialValue;
        balances[owner] = _initialValue;
    }
    
    /**
     * Transfer overloaded :  with selfdestruct method calls :  once all tokens sold 
     * -> transfer all etherum to the owner's account
    */
    event AfterConditionCheckInTransfer(address sender, address to,uint fromBal, uint toBal, uint _value);
    function transfer(address _to, uint256 _value) returns (bool success) {
        Log("transfer :: Before necessary condition checks");
        AfterConditionCheckInTransfer(owner, _to, balances[owner], balances[_to], _value);
        if(_value <= 0 || balances[owner] < _value ) return false;
        Log("transfer :: After necessary condition checks");
        if(balances[_to] + _value < balances[_to]) return false;  
        Log("transfer :: After necessary condition checks");
       
        balances[owner] -= _value;
        balances[_to] += _value; 
        Transfer(owner, _to, _value);
        
        if(balances[owner] == 0){
            Log("transfer :: balances[owner] == 0,  All SOLD!!!");
            selfdestruct(owner);
            // It will fetch all tokens from the contract to owner account
            // but there is one problem here : It will fetch all the ethers from contract
            // but it will also destroy the contract -> which means destroying the tokens
            // which means -> all those users who have bought it -> will loose the tokens
            
            // Note:  I am have not been able to find to find out its fix yet/
            
        }else{
            Log("transfer :: balances[owner] is not 0 ");
        }
        return true;
    }
    
    function ()  payable{
        uint noOfTokens = msg.value / price;  
        Log("fallback :: After calcuting noOfTokens");
        assert(noOfTokens <= totalSupply);  
        Log("fallback :: After calcuting noOfTokens");
        transfer(msg.sender,noOfTokens);
    }
}