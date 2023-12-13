import Account "account";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";

// https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=4118810132

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
        return;
    };

    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
        return #err("Not implemented");
    };

    public query func balanceOf(account : Account) : async Nat {
        return 0;
    };

    public query func totalSupply() : async Nat {
        return 0;
    };

};