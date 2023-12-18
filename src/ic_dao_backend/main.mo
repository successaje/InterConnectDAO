// https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/?tag=2567882399

import Http "utilities/http";
import Account "utilities/account";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Array "mo:base/Array";

actor class ICDAO() = this {  

  let logo : Text = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"512\" height=\"512\" xml:space=\"preserve\"><g fill-rule=\"evenodd\" clip-rule=\"evenodd\"><path fill=\"#1E62D6\" d=\"M128 352c53.023 0 96-42.977 96-96h32c0 70.688-57.309 128-128 128S0 326.688 0 256c0-70.691 57.309-128 128-128 31.398 0 60.141 11.344 82.406 30.117l-.039.059c3.414 2.93 5.625 7.215 5.625 12.082 0 8.824-7.156 16-16 16-3.859 0-7.371-1.434-10.145-3.723l-.039.059C173.109 168.516 151.562 160 128 160c-53.023 0-96 42.977-96 96s42.977 96 96 96z\"/><path fill=\"#FF0083\" d=\"M352 384c-8.844 0-16-7.156-16-16s7.156-16 16-16c53.023 0 96-42.977 96-96s-42.977-96-96-96-96 42.977-96 96h-32c0-70.691 57.312-128 128-128s128 57.309 128 128c0 70.688-57.312 128-128 128zm-64-48c8.844 0 16 7.156 16 16s-7.156 16-16 16-16-7.156-16-16 7.156-16 16-16z\"/></g></svg>";

  // lvl 2
  public type Member = {
        name : Text;
        userName : Text;
        email : ?Text;
        age : ?Nat;
        joinAs : UserType;
    };

    public type UserType = { #Org; #Reg };
    public type Result<A, B> = Result.Result<A, B>;
    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    var members : HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
      switch(members.get(caller)){
        case(null){
          if (not(usernameChecker(member.userName))){
            return #err("Username exists, need to be unique");
          };
          members.put(caller, member);
          return #ok();
        }; case(_){
          return #err("User already exists");
        }
      }
    };

    func usernameChecker(username : Text) : Bool {
      var unique = true;
      for ((i, j) in members.entries()) {
          if (j.userName == username) {
              unique := false;
          };
      };
      unique;
    };



    public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
      switch(members.get(caller)){
        case(null){
          return #err("You are not a member");
        }; case(_){
          members.put(caller, member);
          return #ok()
        }
      }
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch(members.get(caller)){
        case(null){
          return #err("You are not a member");
        }; case(_){
          members.delete(caller);
          return #ok()
        }
      }
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch(members.get(p)){
        case(null){
          return #err("You are not a member");
        }; case(?member){
          return #ok(member);
        }
      }
    };

    func isDAOMember(account : Principal) : Bool {
      switch (members.get(account)){
        case(null){
          return false
        }; case (?members){
          return true;
        }
      }
    };

    public query func getAllMembers() : async [Member] {
        return Iter.toArray(members.vals());
    };

    public query func numberOfMembers() : async Nat {
        return members.size();
    };
  
  // lvl 3

  let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap(Account.accountsEqual, Account.accountsHash);

  let token_Name = "Aje DAO";
  let token_Symbol = "AJD";


    // For this level make sure to use the helpers function in Account.mo
    public type Subaccount = Blob;
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

    func _burnTokens(caller : Principal, burnAmount : Nat) {
        let defaultAccount = { owner = caller; subaccount = null };
        switch (ledger.get(defaultAccount)) {
            case (null) { return };
            case (?some) { ledger.put(defaultAccount, some - burnAmount) };
        };
    };

    func hasEnoughToken(owner : Principal, n : Nat) : Bool {
      let user = { 
        owner = owner; 
        subaccount = null 
      };
      let balance = _balanceOf(user);
      if (n > balance) {
        return false;
      };
      return true;

    };

     func _balanceOf(account : Account) : Nat {
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
  
  public type Status = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Proposal = {
        id : Nat;
        status : Status;
        manifest : Text;
        votes : Int;
        voters : [Principal];
    };

    var nextProposalId : Nat = 0;

    public type CreateProposalOk = Nat;

    let proposals = TrieMap.TrieMap<Nat, Proposal>(Nat.equal, Hash.hash);

    public type CreateProposalErr = {
        #NotDAOMember;
        #NotEnoughTokens;
    };

    public type CreateProposalResult = Result<CreateProposalOk, CreateProposalErr>;

    public type VoteOk = {
        #ProposalAccepted;
        #ProposalRefused;
        #ProposalOpen;
    };

    public type VoteErr = {
        #NotDAOMember;
        #ProposalNotFound;
        #NotEnoughTokens;
        #AlreadyVoted;
        #ProposalEnded;
    };

    public type voteResult = Result<VoteOk, VoteErr>;

    
    public shared ({ caller }) func createProposal(manifest : Text) : async CreateProposalResult {

      if (not (isDAOMember(caller))) {
        return #err(#NotDAOMember);
      };

      if (not (hasEnoughToken(caller, 2))) {
        return #err(#NotEnoughTokens)
      };

      let pid = nextProposalId;

      let proposal : Proposal = {
        id = pid;
        status = #Open;
        manifest;
        votes = 0;
        voters = [];
      };
      proposals.put (pid, proposal);
      _burnTokens(caller, 2);
      nextProposalId += 1;
      return #ok(pid);
    };

    public query func getProposal(id : Nat) : async ?Proposal {
        return proposals.get(id);
    };

    func _isProposalOpen(proposal : Proposal) : Bool {
        switch (proposal.status) {
            case (#Open) {
                return true;
            };case (_) {
                return false;
            };
        };
    };

    func _hasAlreadyVoted(p : Principal, proposal : Proposal) : Bool {
        for (voter in proposal.voters.vals()) {
            if (voter == p) {
                return true;
            };
        };
        return false;
    };

    public shared ({ caller }) func vote(id : Nat, vote : Bool) : async voteResult {

      if (not (isDAOMember(caller))) {
            return #err(#NotDAOMember);
        };
        
        if (not (hasEnoughToken(caller, 1))) {
            return #err(#NotEnoughTokens);
        };

        switch (proposals.get(id)) {
            case (null) {
                return #err(#ProposalNotFound);
            };
            case (?proposal) {
                if (not (_isProposalOpen(proposal))) {
                    return #err(#ProposalEnded);
                };
                if (_hasAlreadyVoted(caller, proposal)) {
                    return #err(#AlreadyVoted);
                };

                let newVotes = switch (vote) {
                    case (true) {
                        proposal.votes + 1;
                    };
                    case (false) {
                        proposal.votes - 1;
                    };
                };

                let newStatus = switch (newVotes) {
                    case (10) {
                        #Accepted;
                    };
                    case (-10) {
                        #Rejected;
                    };
                    case (_) {
                        #Open;
                    };
                };

                 let newVoters = Array.append<Principal>(proposal.voters, [caller]);

                let newProposal : Proposal = {
                    id = proposal.id;
                    status = newStatus;
                    manifest = proposal.manifest;
                    votes = newVotes;
                    voters = newVoters;
                };

                proposals.put(proposal.id, newProposal);

                let returnValue = switch (newStatus) {
                    case (#Open) {
                        #ProposalOpen;
                    };
                    case (#Accepted) {
                        #ProposalAccepted;
                    };
                    case (#Rejected) {
                        #ProposalRefused;
                    };
                };
                return #ok(returnValue);
            };
        };
    };

    public type DAOStats = {
        name : Text;
        manifesto : Text;
        goals : [Text];
        member : [Text];
        logo : Text;
        numberOfMembers : Nat;
    };

    public type HttpRequest = Http.Request;
    public type HttpResponse = Http.Response;

    public query func http_request(request : HttpRequest) : async HttpResponse {
      let response = {
          body = Text.encodeUtf8("Hello world");
          headers = [("Content-Type", "text/html; charset=UTF-8")];
          status_code = 200 : Nat16;
          streaming_strategy = null
      };
      return(response)
    };

    public query func getStats() : async DAOStats {
        return ({
            name = "";
            manifesto = "";
            goals = [];
            member = [];
            logo = logo;
            numberOfMembers = 0;
        });
    };



    

    

    
}