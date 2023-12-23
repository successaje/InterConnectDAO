import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";


actor class Token(_name: Text, _symbol: Text, _decimals: Nat, _initialSupply: Nat, _owner: Principal) {

    private stable var owner_ : Principal = _owner;
    private stable let name_ : Text = _name;
    private stable let decimals_ : Nat = _decimals;
    private stable let symbol_ : Text = _symbol;
    private stable var totalSupply_ : Nat = _initialSupply;

    private var balances =  HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    private var allowances = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Nat>>(1, Principal.equal, Principal.hash);

    balances.put(owner_, totalSupply_);

    private shared func increaseSupply(amount: Nat) : async () {
        // Logic to increase the total supply by `amount`
        totalSupply_ += amount;
    };

    public shared ({ caller }) func transfer(to:Principal, value: Nat) : async Bool {
        switch(balances.get(caller)){
            case(?from_balance) {
                if (from_balance >= value) {
                    var from_balance_new : Nat = from_balance - value;
                    assert(from_balance_new <= from_balance);
                    balances.put(caller, from_balance_new);

                    var to_balance_new = switch (balances.get(to)) {
                        case (?to_balance) {
                            to_balance + value;
                        }; case (_) {
                            value;
                        };
                    };
                    assert(to_balance_new >= value);
                    balances.put(to, to_balance_new);
                    return true;
                } else {
                    return false;
                };
            }; case (_) {
                return false;
            };
        }
    };

    public shared(msg) func transferFrom(from: Principal, to: Principal, value: Nat) : async Bool {
        switch (balances.get(from), allowances.get(from)) {
            case (?from_balance, ?allowance_from) {
                switch (allowance_from.get(msg.caller)) {
                    case (?allowance) {
                        if (from_balance >= value and allowance >= value) {
                            var from_balance_new : Nat = from_balance - value;
                            assert(from_balance_new <= from_balance);
                            balances.put(from, from_balance_new);

                            var to_balance_new = switch (balances.get(to)) {
                                case (?to_balance) {
                                   to_balance + value;
                                };
                                case (_) {
                                    value;
                                };
                            };
                            assert(to_balance_new >= value);
                            balances.put(to, to_balance_new);

                            var allowance_new : Nat = allowance - value;
                            assert(allowance_new <= allowance);
                            allowance_from.put(msg.caller, allowance_new);
                            allowances.put(from, allowance_from);
                            return true;                            
                        } else {
                            return false;
                        };
                    };
                    case (_) {
                        return false;
                    };
                }
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func approve(spender: Principal, value: Nat) : async Bool {
        switch(allowances.get(msg.caller)) {
            case (?allowances_caller) {
                allowances_caller.put(spender, value);
                allowances.put(msg.caller, allowances_caller);
                return true;
            };
            case (_) {
                var temp = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
                temp.put(spender, value);
                allowances.put(msg.caller, temp);
                return true;
            };
        }
    };

    




}