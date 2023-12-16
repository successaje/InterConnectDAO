import Account "account";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

actor class DAO()  {

  let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap(Account.accountsEqual, Account.accountsHash);

  let token_Name = "Aje DAO";
  let token_Symbol = "AJD";


    // For this level make sure to use the helpers function in Account.mo
    public type Subaccount = Blob;
    public type Result<A,B> = Result.Result<A,B>;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    public query func tokenName() : async Text {
        return token_Name;
    };

    public query func tokenSymbol() : async Text {
        return token_Symbol;
    };

    public func mint(owner : Principal, amount : Nat) : async () {
      let user = { 
        owner = owner; 
        subaccount = null 
      };
        switch (ledger.get(user)) {
            case (null) {
                ledger.put(user, amount);
            };
            case (?some) {
                ledger.put(user, some + amount);
            };
        };
  
        return;
    };

    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
        let checkBalance = switch (ledger.get(from)) {
            case (null) { 0 };
            case (?val) { val };
        };
        if (checkBalance < amount) {
            return #err("You do not have enough balance");
        };
        let toBalance = switch (ledger.get(to)) {
            case (null) { 0 };
            case (?some) { some };
        };
        ledger.put(from, checkBalance - amount);
        ledger.put(to, toBalance + amount);
        return #ok();
    };

    public query func balanceOf(account : Account) : async Nat {
        return switch (ledger.get(account)) {
            case (null) { 0 };
            case (?some) { some };
        };
    };

    public query func totalSupply() : async Nat {
        var totalSupply = 0;
        for (balance in ledger.vals()) {
            totalSupply += balance;
        };
        return totalSupply;
    };

};