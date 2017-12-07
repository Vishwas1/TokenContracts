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